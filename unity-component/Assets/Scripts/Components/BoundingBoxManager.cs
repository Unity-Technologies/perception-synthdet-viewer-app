using System;
using System.Collections.Generic;
using System.Linq;
using GameObjects;
using JetBrains.Annotations;
using Models;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

namespace Components
{
    [RequireComponent(typeof(ARRaycastManager))]
    public class BoundingBoxManager : MonoBehaviour
    {
        public GameObject placedPrefab;
        public ARCameraManager cameraManager;
    
        // ARRaycastManager component used for doing raycasts onto planes in AR
        private ARRaycastManager _arRaycastManager;
    
        // List of bounding boxes currently on screen
        private static List<GameObject> _boundingBoxes = new List<GameObject>();

        private const int SurroundingPixelDistance = 10; // Amount of pixels to go out in each direction when finding distance per pixel
        private const float LabeledBoundingBoxScale = 0.1f; // Scale of LabeledBoundingBox prefab
        private const float RectangleScale = 0.1f; // Scale of rectangle on LabeledBoundingBox prefab
        private const int TransientBoxUpdateCount = 1; // Amount of updates a box can go through without being reused

        private void Awake()
        {
            _arRaycastManager = GetComponent<ARRaycastManager>();
        }

        public void SetObjectClassifications(List<ObjectClassification> classifications)
        {
            _boundingBoxes.RemoveAll(box =>
            {
                if (box.GetComponent<LabeledBoundingBox>().UpdatesRemaining == 0)
                {
                    Destroy(box);
                    return true;
                }

                return false;
            });
        
            _boundingBoxes.ForEach(box => box.GetComponent<LabeledBoundingBox>().UpdatesRemaining -= 1);
        
            classifications.ForEach(AddObjectClassification);
        }

        // Adds an ObjectClassification to the AR view, either by creating a new box or reusing an old one that is nearby
        private void AddObjectClassification(ObjectClassification objectClassification)
        {
            List<ARRaycastHit> raycastHits = new List<ARRaycastHit>();
        
            var middle = objectClassification.box.MiddlePoint();
        
            // Convert from y-increases-downward to y-increases-upward coordinate space
            middle.y = Screen.height - middle.y;
        
            // Attempt to raycast
            if (_arRaycastManager.Raycast(middle, raycastHits, TrackableType.PlaneWithinPolygon))
            {
                var raycastHitPosition = raycastHits[0].pose.position;
                var surroundingHits = new List<List<ARRaycastHit>>();
                new List<Vector2> { Vector2.down, Vector2.left, Vector2.up, Vector2.right }
                    // Go out by several pixels in each direction
                    .ConvertAll(it => it * SurroundingPixelDistance + middle)
                    .ForEachIndexed((position, index) =>
                    {
                        surroundingHits.Add(new List<ARRaycastHit>());
                    
                        // Do a raycast to each surrounding position
                        _arRaycastManager.Raycast(position, surroundingHits[index], TrackableType.PlaneWithinPolygon);
                    });

                var validSurroundingPointCount = surroundingHits
                    .FindAll(points => points.Count > 0)
                    .Count;

                var distancePerPixel = surroundingHits
                    .FindAll(hits => hits.Count > 0)
                    .ConvertAll(hits => hits.First().pose.position)
                    .Aggregate(0.0f, (avg, position) => 
                        avg + (position - raycastHitPosition).magnitude / validSurroundingPointCount / SurroundingPixelDistance);
            
                var hitPosition = raycastHits[0].pose.position;
                var boundingBoxGameObject = FindCloseBoundingBoxForObject(objectClassification, hitPosition);

                if (boundingBoxGameObject != null)
                {
                    Console.WriteLine("Re-using bounding box at center: " + hitPosition);
                
                    var boundingBox = boundingBoxGameObject.GetComponent<LabeledBoundingBox>();

                    boundingBox.UpdatesRemaining = TransientBoxUpdateCount;
                    boundingBox.SetPredictionScore(objectClassification.score);
                }
                else
                {
                    Console.WriteLine("Added bounding box at center: " + hitPosition);

                    _boundingBoxes.Add(GetNewBoundingBoxForClassification(objectClassification, hitPosition, distancePerPixel));
                }
            }
            else // If it can't raycast, try to reuse any old box with the same label
            {
                var boundingBoxWithLabel = FindCloseBoundingBoxForObject(objectClassification, null);
                if (boundingBoxWithLabel != null)
                {
                    Console.WriteLine("Re-using bounding box at old center: " + boundingBoxWithLabel.transform.position);
                
                    var boundingBox = boundingBoxWithLabel.GetComponent<LabeledBoundingBox>();

                    boundingBox.UpdatesRemaining = TransientBoxUpdateCount;
                    boundingBox.SetPredictionScore(objectClassification.score);
                }
            }
        }

        // Adds a bounding box game object into the AR world
        private GameObject GetNewBoundingBoxForClassification(ObjectClassification classification, 
            Vector3 position, float distancePerPixel)
        {
            var boxGameObject = Instantiate(placedPrefab, position, cameraManager.transform.rotation);
            var boundingBox = boxGameObject.GetComponent<LabeledBoundingBox>();
            
            boundingBox.SetWidth(classification.box.Size().x * distancePerPixel / LabeledBoundingBoxScale / RectangleScale);
            boundingBox.SetHeight(classification.box.Size().y * distancePerPixel / LabeledBoundingBoxScale / RectangleScale);
            boundingBox.SetColor(BoxColors.ColorForItemLabel(classification.label) ?? Color.black);
            boundingBox.SetLabel(classification.label);
            boundingBox.SetPredictionScore(classification.score);
            boundingBox.UpdatesRemaining = TransientBoxUpdateCount;

            return boxGameObject;
        }

        // Finds a possible matching bounding box for the given ObjectClassification. Returns that box if found, otherwise null
        [CanBeNull]
        private GameObject FindCloseBoundingBoxForObject(ObjectClassification objectClassification, Vector3? center)
        {
            var candidateBoxes = _boundingBoxes
                .FindAll(box => box.GetComponent<LabeledBoundingBox>().GetLabel() == objectClassification.label);

            if (candidateBoxes.Count == 0)
            {
                return null;
            }

            var closestBox = candidateBoxes.First();

            if (center == null)
            {
                return closestBox;
            }
        
            foreach (var box in candidateBoxes)
            {
                if ((closestBox.transform.position - center.Value).magnitude 
                    < (box.transform.position - center.Value).magnitude)
                {
                    closestBox = box;
                }
            }

            return closestBox;
        }
    }
}
