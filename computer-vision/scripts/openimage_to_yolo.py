# ---------------
# Date: 7/25/2018
# Place: Biella
# Author: EscVM
# https://gist.github.com/EscVM/b6e5d60343c88f358742aa9e0de2cc3f
# Project: OID v4 to Yolo
# ---------------


import os
from tqdm import tqdm
from sys import exit
import argparse
import cv2
from textwrap import dedent

ROOT_DIR = '../../../softwares/OIDv4_ToolKit/OID'
OUTPUT_DIR = '../data/'
NAME_DIR = 'Ambulance'


def argument_parser():
    parser = argparse.ArgumentParser(description='Convert OID format to Yolo')
    parser.add_argument("command",
                        metavar="<command> 'convert' or 'dummy'",
                        help="'convert oid format to yolo' or 'dummy', add no target images")
    parser.add_argument('--dataset', required=True,
                        metavar="type of dataset: 'validation', 'test', 'train', 'all'",
                        help='"validation" or "train" or "test" or "all"')
    parser.add_argument('--class_name', required=True,
                        metavar="name of the class to convert",
                        help='Convert: name of the class Ex: "Apple" Dummy: where to add images')
    parser.add_argument('--class_number', required=False,
                        default=0,
                        metavar="dictionary value of the class",
                        help="It's the value assigned to the class")
    parser.add_argument('--copy', required=False,
                        default=False,
                        metavar="boolean: copy images in a common folder",
                        help="copy images with labels in a common folder")
    parser.add_argument('--names', required=False,
                        default=False,
                        metavar="boolean: create .names file with classes",
                        help="boolean: create .names file with classes")
    parser.add_argument('--dummy_name', required=False,
                        default=False,
                        metavar="class_name to add as dummy to class_name",
                        help="add images to class_name with void labels")
    parser.add_argument('--move', required=False,
                        default=False,
                        metavar="boolean: move images from original folder",
                        help="if '1' moves imase to To_YOLO folder")

    args = parser.parse_args()

    return args


class Engine(object):

    global ROOT_DIR
    global OUTPUT_DIR
    global NAME_DIR

    def __init__(self, dataset, class_name, class_number, copy, names, move):
        self.dataset = dataset
        self.class_name = class_name
        self.class_number = class_number
        self.copy = copy
        self.names = names
        self.move = move

        self.class_list = []

    def run_converter(self):

        self.make_start()

        if self.dataset != 'all':
            self.dataset_dir = os.path.join(ROOT_DIR, 'Dataset', self.dataset, self.class_name)
            self.label_dir = os.path.join(self.dataset_dir, 'Label')
            self.output_dataset_dir = os.path.join(OUTPUT_DIR, NAME_DIR, self.dataset, self.class_name)

            if not os.path.exists(self.output_dataset_dir):
                os.makedirs(self.output_dataset_dir)

            self.img_file = os.listdir(self.dataset_dir)

            print("[INFO] {} images found".format(len(self.img_file) - 1))
            print("[INFO] ----  x | y | width | height  ---- output format".format(len(self.img_file) - 1))

            self.make_labels()

            if self.names == '1':
                self.make_names()

        else:
            dataset_DIR = os.path.join(ROOT_DIR, 'Dataset')
            dataset_list = tuple(os.listdir(dataset_DIR))
            for dataset in dataset_list:
                self.dataset_dir = os.path.join(ROOT_DIR, 'Dataset', dataset, self.class_name)
                self.label_dir = os.path.join(self.dataset_dir, 'Label')
                self.output_dataset_dir = os.path.join(OUTPUT_DIR, NAME_DIR, dataset, self.class_name)

                if not os.path.exists(self.output_dataset_dir):
                    os.makedirs(self.output_dataset_dir)

                self.img_file = os.listdir(self.dataset_dir)

                print("[INFO] {} images found".format(len(self.img_file) - 1))
                print("[INFO] ----  x | y | width | height  ---- output format".format(len(self.img_file) - 1))

                self.make_labels()

                if self.names == '1':
                    self.make_names()

    def run_dummy(self, dummy_name):

        self.make_start()

        dataset_dir = os.path.join(ROOT_DIR, 'Dataset', self.dataset, dummy_name)
        self.output_dataset_dir = os.path.join(OUTPUT_DIR, NAME_DIR, self.dataset, self.class_name)

        if not os.path.exists(self.output_dataset_dir):
            print("The selected output folder does not exists")
            exit(1)

        img_file = os.listdir(dataset_dir)

        print("[INFO] {} images found".format(len(img_file) - 1))
        print("[INFO] VOID output format".format(len(img_file) - 1))

        for element in tqdm(img_file):
            if element.endswith('.jpg'):
                img_path = os.path.join(dataset_dir, element)
                self.img_path_yolo = os.path.join(self.output_dataset_dir, element)
                img_name = str(element.split('.')[0]) + '.txt'
                label_path_yolo = os.path.join(self.output_dataset_dir, img_name)

                self.img = cv2.imread(img_path)

                label_yolo = open(label_path_yolo, 'w')

                label_yolo.close()

                if self.copy == '1':
                    self.make_copy()

                if self.move == '1':
                    self.make_copy()


        self.make_end()


    def make_labels(self):

        for element in tqdm(self.img_file):
            if element.endswith('.jpg'):
                self.img_path = os.path.join(self.dataset_dir, element)
                self.img_path_yolo = os.path.join(self.output_dataset_dir, element)
                img_name = str(element.split('.')[0]) + '.txt'
                self.label_path_original = os.path.join(self.label_dir, img_name)
                label_path_yolo = os.path.join(self.output_dataset_dir, img_name)

                self.img = cv2.imread(self.img_path)
                label_original = open(self.label_path_original, 'r')

                label_yolo = open(label_path_yolo, 'w')

                for line in label_original:
                    # name_of_class X_min Y_min X_max Y_max
                    line = line.strip()
                    l = line.split(' ')

                    class_name = l.pop(0)
                    try:
                        float(l[0])
                    except ValueError:
                        class_name += ' ' + l.pop(0)

                    if class_name not in self.class_list:
                        self.class_list.append(class_name)

                    for i in range(len(l)):
                        l[i] = float(l[i])
                    x = ((l[2] + l[0]) / 2)
                    y = ((l[3] + l[1]) / 2)
                    width = (l[2] - l[0])
                    height = (l[3] - l[1])

                    img_width = 1 / self.img.shape[1]
                    img_height = 1 / self.img.shape[0]

                    x *= img_width
                    y *= img_height
                    width *= img_width
                    height *= img_height

                    if self.class_number != 0:
                        c_name = self.class_number
                    else:
                        c_name = self.class_list.index(class_name)

                    print("{0} {1} {2} {3} {4}".format(c_name, x, y, width, height), file=label_yolo)

                if self.copy == '1':
                    self.make_copy()

                if self.move == '1':
                    self.make_copy()
                    self.make_move()

                label_yolo.close()
                label_original.close()

        self.make_end()

    def make_copy(self):
        cv2.imwrite(self.img_path_yolo, self.img)

    def make_move(self):
        os.remove(self.img_path)
        os.remove(self.label_path_original)

    def make_names(self):

            file_path = os.path.join(OUTPUT_DIR, NAME_DIR, 'obj.names')
            f = open(file_path, 'w')
            for i in range(len(self.class_list)):
                print("{}".format((self.class_list[i]).lower()), file=f)
            f.close()

    def make_end(self):
        if self.copy == '1':
            print("[INFO] Done!")
            print("[INFO] There are {} images in your dataset".format(len(os.listdir(self.output_dataset_dir)) / 2))

        else:
            print("[INFO] Done!")
            print("[INFO] There are {} images in your dataset".format(len(os.listdir(self.output_dataset_dir))))

    def make_start(self):
       print(dedent("""
   _____  ____  ____  _  _  __  
  (  _  )(_  _)(  _ \( \/ )/. | 
   )(_)(  _)(_  )(_) )\  /(_  _)
  (_____)(____)(____/  \/   (_) 
	 ____  _____ 
	(_  _)(  _  )
	  )(   )(_)( 
	 (__) (_____)
    _  _  _____  __    _____ 
   ( \/ )(  _  )(  )  (  _  )
    \  /  )(_)(  )(__  )(_)( 
    (__) (_____)(____)(_____)
             """))




if __name__ == '__main__':


    args = argument_parser()


    if args.command == 'convert':

        converter = Engine(args.dataset, args.class_name, args.class_number, args.copy, args.names, args.move)

        converter.run_converter()

    if args.command == 'dummy':

        dummy_generator = Engine(args.dataset, args.class_name, args.class_number, args.copy, args.names, args.move)

        dummy_generator.run_dummy(args.dummy_name)

