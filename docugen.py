#!/usr/bin/python3
# Docugen can generate documentation from source code
# Created by Ali Rıza KESKİN (sulincix)

import sys
import os
import re

paths=[]

def get_path(path):
    if os.path.isfile(path) and re.search(".py$",path):
        print("Import:"+path)
        paths.append(path)
    elif os.path.isdir(path):
        for p in os.listdir(path):
            get_path((path+"/"+p).replace("//","/"))

for path in sys.argv[1:]:
    get_path(path)

for path in paths:
    docstr=""
    docdir="./doc/"
    docname=""
    d="#DOC:"
    dty=".rst"
    if os.path.exists(re.sub(".py$",".rst",path)):
        os.unlink(re.sub(".py$",".rst",path))
    file=open(path,"r").read()
    for line in file.split("\n"):
        line=line.strip()
        if "#DOCDIR:" in line and line.strip()[0] == "#":
            docdir=line.split("#DOCDIR:")[1].strip()+"/"
        if "#DOCNAME:" in line and line.strip()[0] == "#":
            docname=line.split("#DOCNAME:")[1].strip()
        if "#DOCTYPE:" in line and line.strip()[0] == "#":
            dty="."+line.split("#DOCTYPE:")[1].strip()
        if "#DOCSTR:" in line and line.strip()[0] == "#":
            d="#"+line.split("#DOCSTR:")[1].strip()+":"
        if d in line and line.strip()[0] == "#":
            docstr+=line.split(d)[1]+"\n"
    if not os.path.exists(docdir):
        os.makedirs(docdir)
    if len(docstr) > 0:
        path=docdir+path.split("/")[-1]
        print("Generate: "+path+str(len(docstr)))
        if docname == "":
            out=open(re.sub(".py$",dty,path),"w")
        else:
            out=open(docdir+docname+dty,"w")
        out.write(docstr)

