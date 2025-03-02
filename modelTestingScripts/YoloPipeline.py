import logging.config
import ultralytics
import logging
import subprocess
import seaborn as sns 
import matplotlib.pyplot as plt
import os
from typing import Union, Tuple

"""
    This file is where the testing script will reside, the pipeline as well as the loging functions will be in this unique file
    
    Imported libraries:
        Ultralytics: needed for YOLO model 
        loggign: will be used to log the outputs of the model
        seaborn and matplot will be used to plot the data into a visual representaiton
        
    
"""

#logging config
logging.basicConfig(level=logging.INFO, format = '[%(levelname)s] %(message)s')


class YOLOPipeline:
    def __init__(self,
                 model_path: str,
                 export_path: str,
                 test_image: list[str] = ["path/to/test_image.jpg"],
                 export_format: str = 'coreml',
                 imgsz: Union[int, Tuple[int,int]] = 640,
                 half: bool = False,
                 int8: bool = False,
                 nms: bool = False,
                 batch: int =1,
                 ):
        
        self.model_path = model_path
        self.export_path = export_path
        self.test_image = test_image
        self.export_format = export_format
        self.imgsz = imgsz
        self.half = half
        self.int8 = int8
        self.nms = nms
        self.batch = batch
    
    def load_model(self) -> None:
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
    
    def run_tests(self) -> None:
        """
        runs an inference test on a test image to verify that the model is working as expected
        """
        if not self.model:
            logging.error("Model not loaded. Please load the model before testing")
            return
        
        logging.info("running tests on the model")
        
        try:
            testCounter: int = 0
            for image in self.test_image:
                logging.info(f"test {testCounter} begins")
                result = self.model.predict(source=image)
                logging.info(f"test {testCounter} completed with result: {result}")
                testCounter +=1
        except Exception as e:
            logging.error(f"test {testCounter} failed, {e}")
            raise

        logging.info("all tests completed successfully!")
        
        # try:
        #     for image in self.test_image:
        #         result = self.model.predict(source=image)
        #         logging.info(f"Model test completed. result: {result}")
        # except Exception as e:
        #     logging.error(f"Testing failed: {e}")
        #     raise
    
    
    def build_export_command(self) -> list:
        pass
    
    def convert_to_coreml(self) -> None:
        
        logging.info("Converting model to coreml format...")
        
        pass
    
    def compress_model(self) -> None:
        """
            We might not need this since our model is quite small
            
        """
        pass
    
    def fullpipeline(self) -> None:
        """
            Runs the entire pipeline: loading, testing, converting and compressing the model
        """
        self.load_model()
        self.run_tests()
        self.convert_to_coreml()
        self.compress_model()
        
if __name__ == "__main__":
    pipeline = YOLOPipeline()
    pipeline.fullpipeline()
        
        
        
    
            
    