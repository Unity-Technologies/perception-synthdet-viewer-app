using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;

namespace Models.Coco
{
    [Serializable]
    public class CocoDocument
    {
        public CocoInfo info;
        public List<CocoLicense> licenses = new List<CocoLicense>();
        public List<CocoCategory> categories = new List<CocoCategory>();
        public List<CocoImage> images = new List<CocoImage>();
        public List<CocoAnnotation> annotations = new List<CocoAnnotation>();

        public static CocoDocument CreateEmptyDocument() =>
            new CocoDocument
            {
                info = new CocoInfo(DateTime.Now.Year.ToString(),
                    "1.0",
                    "COCO Export of Captures from Unity Object Detection App",
                    "Unity Technologies, Inc.",
                    "",
                    DateTime.Now.ToString(CultureInfo.InvariantCulture)),
                licenses = new List<CocoLicense> {new CocoLicense(1, "Unknown", "")},
                categories = Enumerable.Range(1, 64).ToList()
                    .ConvertAll(n => new CocoCategory(n, n.ToString(), "label_id")),
                images = new List<CocoImage>(),
                annotations = new List<CocoAnnotation>()
            };
    }

    [Serializable]
    public class CocoInfo
    {
        public string year;
        public string version;
        public string description;
        public string contributor;
        public string url;
        public string date_created;

        public CocoInfo(string year, string version, string description, string contributor, string url, string dateCreated)
        {
            this.year = year;
            this.version = version;
            this.description = description;
            this.contributor = contributor;
            this.url = url;
            date_created = dateCreated;
        }
    }

    [Serializable]
    public class CocoLicense
    {
        public int id;
        public string name;
        public string url;

        public CocoLicense(int id, string name, string url)
        {
            this.id = id;
            this.name = name;
            this.url = url;
        }
    }

    [Serializable]
    public class CocoCategory
    {
        public int id;
        public string name;
        public string supercategory;

        public CocoCategory(int id, string name, string supercategory)
        {
            this.id = id;
            this.name = name;
            this.supercategory = supercategory;
        }
    }

    [Serializable]
    public class CocoImage
    {
        public int id;
        public int width;
        public int height;
        public string file_name;
        public int license;
        public string date_captured;

        public CocoImage(int id, int width, int height, string fileName, int license, string dateCaptured)
        {
            this.id = id;
            this.width = width;
            this.height = height;
            file_name = fileName;
            this.license = license;
            date_captured = dateCaptured;
        }
    }

    [Serializable]
    public class CocoAnnotation
    {
        public int id;
        public int image_id;
        public int category_id;
        public List<int> segmentation;
        public float area;
        public List<int> bbox;
        public int iscrowd;

        public CocoAnnotation(int id, int imageId, int categoryId, List<int> segmentation, float area, List<int> bbox, int iscrowd)
        {
            this.id = id;
            image_id = imageId;
            category_id = categoryId;
            this.segmentation = segmentation;
            this.area = area;
            this.bbox = bbox;
            this.iscrowd = iscrowd;
        }
    }
}
