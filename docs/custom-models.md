## Hosting a custom model
The SynthDet Viewer app expects the following schema for object detection results:
```json
[                                       Array of classifications (array)
    {                                   ObjectClassification (object)
        "label": "",                    Label of object (string)
        "label_id": 0,                  ID of object (int)
        "box": {                        Top-left BoundingBox (object)
            "top_left": {               Point2D (object)
                "x": 0.0,               X coordinate (float)
                "y": 0.0                Y coordinate (float)
            },
            "bottom_right": {           Bottom-right BoundingBox (object)         
                "x": 0.0,
                "y": 0.0
            }
        },
        "score": 0.0                    Prediction score (float)
    }
]
```

The app will send a POST request to an endpoint you specify in the Settings screen. In the body of the POST request, the app supplies JPEG bytes of the image which will be used for inference. The image can be any size.

When your endpoint receives the POST request, it should return a text/json body formatted using the schema above. The lines on the right are descriptions of each property. [TorchServe](https://pytorch.org/serve/) will handle this for you, and it is easiest to start with our [`perception-synthdet-torchserve`](https://github.com/Unity-Technologies/perception-synthdet-torchserve) tool which uses TorchServe. For adapting our tool for your model, read the [Adapting for your Model](https://github.com/Unity-Technologies/perception-synthdet-torchserve/wiki/Adapting-for-your-Model) wiki page.

