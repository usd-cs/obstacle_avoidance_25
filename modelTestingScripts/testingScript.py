from ultralytics import YOLO
import os
import cv2
import re

"""_summary_
    The following script loads the new trained anc coreml converted YOLOv8 model 
    and loads a set of images to it in order to prove that the model is indeed able to predict
    the contents of an image give its training. 
    
    
    NOTE: FOR THIS SCRIPT TO WORK ULTRALYTICS MUST BE INSTALLED --> pip install ultralytics
"""
try:
    
    coremlModel = YOLO("model/best.mlpackage")
except:
    print("Error: could not load the model")


def checkIfPrediction(predictionResult) -> bool:
    output = str(predictionResult)
    match = re.search(r"cls:\s*tensor\(\[\]\)", output)
    
    if match:
        return False
    else: 
        return True



directory = "testingBatch"
for filename in os.listdir(directory):
    
    if filename.lower().endswith(".jpg"): #trying to avoid the annoying ds_store file
        filePath = os.path.join(directory,filename)
        
        if not os.path.exists(filePath):
            print(f"Error: File not found - {filePath}")
            
        try:
            image = cv2.imread(filePath)
            if image is None:
                print(f"could not load image - {filePath}")
            print("##########################################################")
            print(f"for {filename} the output is: ")
            
            results = coremlModel(image)
            for result in results:
                
                print(f"Detections: {result.boxes} \n\n")
                testRestult = checkIfPrediction(result.boxes)
                
                try:
                    assert(testRestult == True)
                except AssertionError:
                    print(f"\033[31m{filename} failed to be detected\033[0m")
                                
        
        
        except Exception as e:
            print(f"Error processing {filename}: {e}")
        
        
