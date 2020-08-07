# coding=UTF-8
from os import path, makedirs
from tkinter import messagebox as msg
from tkinter import filedialog as fd
from tkinter import scrolledtext
import tkinter as tk
import tkinter.ttk as ttk
import numpy as np
import glob
import argparse
import cv2 

#Global vars

fDir   = path.dirname(__file__)
netDir = fDir + '\\Backup'

if not path.exists(netDir):
    makedirs(netDir, exist_ok = True) 

class OOP():
    
    def __init__(self):         ## Initializer
        self.win = tk.Tk()
        self.win.title('Monocular Vision')
        self.create_widgets()
        self.Long_edge_points = ''
        self.Short_edge_points = ''
        self.fName = ' '
        self.all_params = ' '
        self.output_address = ' '
        self.pictureinputaddress = ' '
        self.objpoints = []
        self.imgpoints = []
        self.size = ()

    def Image_restoration(self,restoration_image_address,Saving_of_parameters_address,restoration_image_output_address):
        params = np.load(Saving_of_parameters_address)
        img = cv2.imread('restoration_image_address')

        h,w = img.shape[:2]
        newCameramrx,roi = cv2.getOptimalNewCameraMatrix(params['mtx'],params['dist'],(w,h),1,(w,h))
        dst = cv2.undistort(img,params['mtx'],params['dist'],None,newCameramrx)
        x,y,w,h = roi
        dst = dst[y:y+h,x:x+w]
        cv2.imshow('dst',dst)
        cv2.imwrite('/Users/shantong/Desktop/calibresult.png',dst)        

    def _quit(self):
            self.win.quit()
            self.win.destroy()
            exit()

    def create_widgets(self):
        
        tabControl = ttk.Notebook(self.win)                                 # Create Tab Control

        tab1 = ttk.Frame(tabControl)                                        # Create a tab1 
        tabControl.add(tab1, text='Camera Calibration')                     # Add the tab
        tab2 = ttk.Frame(tabControl)                                        # Create a tab2 
        tabControl.add(tab2, text='Positioning of Corner Points')           # Add the tab
        tab3 = ttk.Frame(tabControl)                                        # Create a tab3 
        tabControl.add(tab3, text='The Calculation of Corner Coordinates')  # Add the tab

        tabControl.pack(expand=1, fill="both")  # Pack to make visible
        
        #Load Files Frame -----------------------------------------------------------------------------------

        mngFilesFrame = ttk.LabelFrame(tab1, text=' Load Files')
        mngFilesFrame.grid(column=0, row=1, sticky='WE', padx=10, pady=5)

        Set_the_params = ttk.LabelFrame(tab1, text=' Set the params')
        Set_the_params.grid(column=1, row=1, sticky='WE', padx=10, pady=5)

        last = ttk.LabelFrame(tab1, text='Analysis')
        last.grid(column=2, row=1, sticky='WE', padx=10, pady=5)
        # Button Callback 
        def getFilePack():
            print('hello from getFilePack')
            #fDir  = path.dirname(__file__)            # 当前文件夹名称
            # https://blog.csdn.net/oXiaoXue123456789/article/details/100107661 
            self.pictureinputaddress = fd.askdirectory(parent=self.win)  # initialdir=fDir
            print(self.pictureinputaddress)
            return self.pictureinputaddress
        
        def setFileOutputAddress():
            print('get outputaddress')
            self.output_address = fd.asksaveasfilename(parent=self.win)
            print(self.output_address)
            return self.output_address
                

        #def click_me(): 
        #    self.Long_edge_points.get()
            
        #    print(self.Long_edge_points)
        #    print(self.Short_edge_points)

        #    return self.Long_edge_points, self.Short_edge_points

        def CameraCalibration():

            criteria = (cv2.TERM_CRITERIA_MAX_ITER + cv2.TERM_CRITERIA_EPS, 30, 0.001)  #criteria 标准
            i=0

            # 准备对象点
            # 获取标定板角点的位置
            objp = np.zeros((8 * 6, 3), np.float32)
            objp[:, :2] = np.mgrid[0:8, 0:6].T.reshape(-1, 2)  # 将世界坐标系建在标定板上，所有点的Z坐标全部为0，所以只需要赋值x和y
            #用存储所有图像的对象点和图像点的数组。
            #objpoints = []  # 真实世界中3D点
            #imgpoints = []  # 图像中的2D点
            images = glob.glob(self.pictureinputaddress+'/*.png') 
            #---------------------------------------------------------------------------------------------------------
            for fname in images:
                img = cv2.imread(fname)
                # cv2.imshow('img',img)
                gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

                self.size = gray.shape[::-1]
                # 找到棋盘角落
                ret, corners = cv2.findChessboardCorners(gray, (8, 6), None)
                print(ret)
                # 如果找到，添加对象点，图像点

                if ret:
                    self.objpoints.append(objp)
                    corners2 = cv2.cornerSubPix(gray, corners, (5, 5), (-1, -1), criteria)  # 在原角点的基础上寻找亚像素角点
                    if [corners2]:
                        self.imgpoints.append(corners2)
                    else:
                        imgpoints.append(corners)
                    cv2.drawChessboardCorners(img, (8, 6), corners, ret)  # 记住，OpenCV的绘制函数一般无返回值
                    cv2.imshow('img', img)
                    cv2.imwrite('/Users/shantong/Downloads/Capture/ooooooooo/'+"%d_cornercalibration.png"%i,img)
                    i+=1
                    cv2.waitKey(10)

            cv2.destroyAllWindows()
            print(self.objpoints,self.imgpoints,self.size)
            return self.objpoints,self.imgpoints,self.size    

        def save_the_Camera_Parameters():
            #objpoints,imgpoints,size = CameraCalibration()
            ret, mtx, dist, rvecs, tvecs = cv2.calibrateCamera(self.objpoints,self.imgpoints,self.size, None, None) #世界坐标系的点，对应的图像坐标点，图片的大小用于初始化标定相机。
            
            Rvecs = []
            for i in range(len(rvecs)):
                AAA,_ = cv2.Rodrigues(rvecs[i])
                Rvecs.append(AAA)
            Tvecs = []
            for i in range(len(tvecs)):
                BBB,_ = cv2.Rodrigues(tvecs[i])
                Tvecs.append(BBB) 
            print('saving...')
            np.savez(self.output_address,ret=ret, mtx=mtx, dist=dist,rvecs = rvecs,tvecs=tvecs,Rvecs=Rvecs,Tvecs=Tvecs) 
            print('saved at',self.output_address)
        # button set 
        ##----------------------------------------------------------------------------------------------------------------  
        lb1 = ttk.Button(mngFilesFrame, text="Load Picture Set", command=getFilePack)     
        lb1.grid(column=0, row=0, sticky=tk.W)

        lb2 = ttk.Button(mngFilesFrame, text="Set the Outputparams Address:", command=setFileOutputAddress)     
        lb2.grid(column=0, row=1, sticky=tk.W) 

        button_startcalibration = ttk.Button(last, text="Start", command=CameraCalibration)
        button_startcalibration.grid(column=3,row=1,sticky=tk.W)
        
        button_startcalibration = ttk.Button(last, text="Save camera params", command=save_the_Camera_Parameters)
        button_startcalibration.grid(column=3,row=2,sticky=tk.W)
        
        ##----------------------------------------------------------------------------------------------------------------  
        self.Long_edge_points = tk.StringVar()
        ttk.Label(Set_the_params, text="Enter the long edge points:").grid(column=0, row=0,sticky = tk.W)
        name_entered1 = ttk.Entry(Set_the_params, width=2, textvariable=self.Long_edge_points)
        
        name_entered1.grid(column=1, row=0)


        self.Short_edge_points = tk.StringVar()
        ttk.Label(Set_the_params, text="Enter the short edge points:").grid(column=0, row=1,sticky = tk.W)
        name_entered2 = ttk.Entry(Set_the_params, width=2, textvariable=self.Short_edge_points)
        
        name_entered2.grid(column=1, row=1)


        #action = ttk.Button(Set_the_params, text="Ok", command=click_me)   
        #action.grid(column=1, row=2)  
        


oop = OOP()

oop.win.mainloop()