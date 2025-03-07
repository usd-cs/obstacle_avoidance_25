import logging.config
import ultralytics
import logging
import torch
import os
from typing import Union, Tuple
import pandas as pd
import matplotlib.pyplot as plt

GREEN = "\033[92m"
RESET = "\033[0m"
YELLOW = "\033[93m"
"""
    This file is where the testing script will reside, the pipeline as well as the logging functions will be in this unique file
    
    Imported libraries:
        Ultralytics: needed for YOLO model --> coremltools must also be installed 
        loggign: will be used to log the outputs of the model
        seaborn and matplot will be used to plot the data into a visual representaiton
        
    
"""

#logging config
logging.basicConfig(level=logging.INFO, format = '[%(levelname)s] %(message)s')


class YOLOPipeline:
    def __init__(
            self,
            model_path: str,
            export_path: str,
            test_image: list[str] = ["path/to/test_image.jpg"],
            labels: list[str] = ["path/to/test/labels"],
            test_results: Union[list,None] = None,
            test_comparison: list[bool] = None,
            export_format: str = 'coreml',
            imgsz: Union[int, Tuple[int,int]] = 640,
            predicted_class: list[int] = None,
            actual_class: list[int] = None,
            half: bool = False,
            int8: bool = False,
            nms: bool = False,
            batch: int =1,
            logToTerminal: bool = True
        ):
        
        self.model_path = model_path
        self.export_path = export_path
        self.test_image = test_image
        self.labels = labels
        self.test_results = test_results
        self.test_comparison = test_comparison
        self.export_format = export_format
        self.imgsz = imgsz
        self.predicted_class = predicted_class
        self.actual_class = actual_class
        self.half = half
        self.int8 = int8
        self.nms = nms
        self.batch = batch
        self.logToTerminal = logToTerminal
    
    def loadModel(self) -> None:
        """
        Loads the model
        """
        try:
            from ultralytics import YOLO
            self.model = YOLO(self.model_path)
            logging.info("Model was loaded sucesfully.")
        except Exception as e:
            logging.error("Failed to load model: %s", e)
            raise
    
    
    """takes the results of the passed test and logs them into a file"""
    def logToFile(self) -> None:
        # temp = testResult[0].boxes
        # print("this is the class--> ", temp.cls)
        # print("this is the confidence --> ", temp.conf)
        data = []
        counter = 0
        names = {
            0: 'bench', 1: 'bicycle', 2: 'branch', 
            3: 'bus', 4: 'bushes', 5: 'car', 6: 'crosswalk', 7: 'door', 
            8: 'elevator', 9: 'fire_hydrant', 10: 'green_light', 11: 'gun', 
            12: 'motorcycle', 13: 'person', 14: 'pothole', 15: 'rat', 16: 'red_light', 
            17: 'scooter', 18: 'stairs', 19: 'stop_sign', 20: 'traffic_cone', 21: 'train', 
            22: 'tree', 23: 'truck', 24: 'umbrella', 25: 'yellow_light', -1:'detection failed'}
        for result in self.test_results:
            
            #classID = result[0].boxes.cls
            try:
                cords = result[0].boxes.xyxy
                cords = cords.tolist()
                cords = cords[0] # for some weird reason the tensor returns a list within a list
                classID = result[0].boxes.cls
                classID = classID.tolist()
                classID = classID[0]
                predictionConf = result[0].boxes.conf
                predictionConf = predictionConf.tolist()
                predictionConf = predictionConf[0]
                predictCheckResult = self.test_comparison[counter]
                predictedClass = self.predicted_class[counter]
                actualClass = self.actual_class[counter]
                objectName = names[classID]
            except: #if this is triggered it means that the tensor had an unconvertible val, most likely meaning that there was no detection
                cords = -1
                classID = -1
                predictionConf = -1
                predictionConf = -1
                predictCheckResult = self.test_comparison[counter]
                predictedClass = names[-1]
                actualClass = self.actual_class[counter]
                objectName = -1
        
            counter +=1
            
            data.append({
                "Class": objectName,
                "Class ID": classID,
                "Confidence": predictionConf,
                "BBox cords": cords,
                "Predicted Class": predictedClass,
                "Actual Class": actualClass,
                "Correct Guess": predictCheckResult
            })
        #converts the list into a pandas object
        df = pd.DataFrame(data)
        
        # Save the DataFrame to a CSV file
        csv_filename = "pipelineResults.csv"
        df.to_csv(csv_filename, index=False)  # Save without index column

        logging.info(f"{GREEN}Results saved to {csv_filename} successfully{RESET}✅")
        
        
    
    def compareResults(self, image: str, result) -> None:
        
        for label in self.labels:
            
            if label[26:-4] == image[26:-4]:
                try:
                    predictedClass = result[0].boxes.cls
                    #predictedClass = int(predictedClass.item()) #converts the object class value from a tensor to an int
                    predictedClass = predictedClass.tolist()
                    predictedClass = predictedClass[0]
                except Exception as e:
                    logging.error(f"{YELLOW}error converting predicted class to int, most likely empty prediction {e}{RESET}")
                    predictedClass = -1 #sets the class id to an error value 
                try:
                    classId = None
                    with open(label, "r") as file:
                        for line in file:
                            classId = int(line.split()[0])
                            break
                        
                    """populates object fields for login latter"""
                    self.predicted_class.append(predictedClass)
                    self.actual_class.append(classId)
                    
                    if classId is not None and classId == predictedClass:
                        self.test_comparison.append(True)
                        return
                    else:
                        self.test_comparison.append(False)
                        return
                        
                except Exception as e:
                    logging.error(f"could not open file {e}")
                    raise
                
                
    
    def runTests(self) -> None:
        """
        runs an inference test on a test image to verify that the model is working as expected
        """
        if not self.model:
            logging.error("Model not loaded. Please load the model before testing")
            return
        
        logging.info(f"running tests on the model... ⏳")
        
        try:
            testCounter: int = 0 
            self.test_results = [] # initializes tests results as a list
            self.test_comparison = []
            self.predicted_class = []
            self.actual_class = []
            
            for image in self.test_image:
                logging.info(f"test {testCounter} begins ⏳")
                result = self.model.predict(source=image)
                self.test_results.append(result)
                
                #we now compare the result of the prediction with its actual value
                self.compareResults(image, result)
                if self.logToTerminal:
                    logging.info(f"test {testCounter} completed with result: {result}")
                else:
                    logging.info(f"{GREEN}test {testCounter} completed successfully{RESET}✅")
                testCounter +=1
                
        except Exception as e:
            logging.error(f"test {testCounter} failed, {e}")
            raise
        
        logging.info(f"{GREEN}all tests completed successfully!{RESET} ✅ ")
    
    
        
    
    def convertToCoreml(self) -> None:
        
        logging.info("Converting model to coreml format...")
        
        try:
            
            self.model.export(
                format=self.export_format,
                imgsz = self.imgsz,
                device="cpu",
                half=self.half,
                int8=self.int8,
                nms=self.nms
            )
        except Exception as e:
            logging.error(f"coreml conversion failed with error: {e}")
            raise
        
        logging.info("CoreMl conversion succeeded!")
    
    def compressModel(self) -> None:
        """
            We might not need this since our model is quite small
            
        """
        pass
    
    def fullPipeline(self) -> None:
        """
            Runs the entire pipeline: loading, testing, converting and compressing the model
        """
        self.loadModel()
        self.runTests() #tests model before conversion
        #self.convertToCoreml()
        #self.runTests() #test the model after conversion correct performance
        self.logToFile()
    
    
def populateArr(directoryPath: str) -> list[str]:
    
    testingList : list[str] = []
    # directoryPath = "testingSet/general/images"
    try:
        for file in os.listdir(directoryPath):
            if file != ".DS_Store":
                file = os.path.join(directoryPath,file)
                testingList.append(file)
        
        return testingList
    except Exception as e:
        logging.error(f"Failed to load directory {e}")


if __name__ == "__main__":
    imageDirectoryPath = "testingSet/general/images"
    labelDirectoryPath = "testingSet/general/labels"
    pipeline = YOLOPipeline(
        "model/best.pt",
        "N/A",
        populateArr("testingSet/general/images"),
        populateArr("testingSet/general/labels"),
        "coreml",
        640,
        logToTerminal=False) 
    pipeline.fullPipeline()
        
        
        
    
            
    