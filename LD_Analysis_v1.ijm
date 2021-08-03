
print("\\Clear")
roiManager("reset");
run("Clear Results");
//	MIT License

//	Copyright (c) 2021 Nicholas Condon n.condon@uq.edu.au

//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:

//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.

//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.


//IMB Macro Splash screen (Do not remove this acknowledgement)
scripttitle="LD script";
version="1.0";
versiondate="03/08/2021";
description="Details: <br>blah <br><br> blah blah  <br> <br> A log file (.txt) will be saved within this directory for recording the processing steps chosen"
    
    showMessage("Institute for Molecular Biosciences ImageJ Script", "<html>" 
    +"<h1><font size=6 color=Teal>ACRF: Cancer Biology Imaging Facility</h1>
    +"<h1><font size=5 color=Purple><i>The Institute for Molecular Bioscience <br> The University of Queensland</i></h1>
    +"<h4><a href=http://imb.uq.edu.au/Microscopy/>ACRF: Cancer Biology Imaging Facility</a><\h4>"
    +"<h1><font color=black>ImageJ Script Macro: "+scripttitle+"</h1> "
    +"<p1>Version: "+version+" ("+versiondate+")</p1>"
    +"<H2><font size=3>Created by Nicholas Condon</H2>"	
    +"<p1><font size=2> contact n.condon@uq.edu.au \n </p1>" 
    +"<P4><font size=2> Available for use/modification/sharing under the "+"<p4><a href=https://opensource.org/licenses/MIT/>MIT License</a><\h4> </P4>"
    +"<h3>   <\h3>"    
    +"<p1><font size=3 \b i>"+description+".</p1>"
   	+"<h1><font size=2> </h1>"  
	+"<h0><font size=5> </h0>"
    +"");


//Log Window Title and Acknowledgement
print("");
print("FIJI Macro: "+scripttitle);
print("Version: "+version+" Version Date: "+versiondate);
print("ACRF: Cancer Biology Imaging Facility");
print("By Nicholas Condon (2018) n.condon@uq.edu.au")
print("");
getDateAndTime(year, month, week, day, hour, min, sec, msec);
print("Script Run Date: "+day+"/"+(month+1)+"/"+year+"  Time: " +hour+":"+min+":"+sec);


//Parameter selection box
ext = ".lsm";
  Dialog.create("Select Script Options");
  	Dialog.addString("File Extension:", ext);
 	Dialog.addMessage("(For example .czi  .lsm  .nd2  .lif  .ims)");
  	Dialog.addMessage(" ");
  	Dialog.show();
ext = Dialog.getString();


print("**** Parameters ****");
print("File extension: "+ext);
print("");

//Section 1: 
//Initial set up commands and Selecting the file and destination before running.
path = getDirectory("Choose a Directory containing tiffs of macropinocytosis");
list = getFileList(path);
resultsDir = path+"Analysis_Results_"+year+"-"+(month+1)+"-"+day+"_at_"+hour+"."+min+"/";
File.makeDirectory(resultsDir);
print("Working Directory Location: "+path);											//Reports working directory location to log
print("");

start = getTime();


for (k=0; k<list.length; k++) {
	if (endsWith(list[k], ext)){
		showProgress(k+1, list.length);
		open(path+list[k]);
		windowtitle = getTitle();
		windowtitlenoext = replace(windowtitle, ext, "");
		print("Opening File: "+(k+1)+" of "+list.length);									//Reports opening file to the log
		print("Filename = "+ windowtitle);
		TotMPSArea = 0;
		
		//Generation of excel spreadsheet
		summaryFile = File.open(resultsDir+"LD_area_Cell_"+windowtitlenoext+".xls");
		print(summaryFile,"ImageId \t Cell Label \t Cell Area \t LD Num \t LD Area\n" );
		run("Clear Results");
		run("Split Channels");

		roiManager("reset");
		run("Clear Results");
		

		selectWindow( "C3-" + windowtitle);
		rename("cellmask");
		setMinAndMax(0, 5000);
 		run("Median...", "radius=2");
		setAutoThreshold("Triangle dark");
		run("Convert to Mask");
  		//run("Analyze Particles...", "size=200-Infinity show=Masks display exclude clear summarize add");  **THIS line excludes edges
 		run("Analyze Particles...", "size=200-Infinity show=Masks display  clear summarize add");
		print("Total Number of cells found = "+nResults);
		
		TotalCellArea=newArray(nResults); 
		for (i=0 ; i<nResults ; i++) {  
 	 	TotalCellArea[i] = getResult("Area", i);
 	 	}
		run("Clear Results");

		selectWindow( "C2-" + windowtitle);
		rename("LD");
		setMinAndMax(300, 3500);
		run("Subtract Background...", "rolling=10");
		setAutoThreshold("Otsu dark");
		run("Convert to Mask");

		for (i=0 ; i<roiManager("count"); i++) {
			selectImage("LD");
			roiManager("select", i);
			roiManager("rename", "Cell "+(i+1))
			run("Clear Results");  
			run("Set Measurements...", "area mean display redirect=None decimal=3");
			run("Analyze Particles...", "size=0.1-15 circularity=0.00-1.00 show=Masks display");
			selectWindow( "Mask of LD"); close();
			for (j=0 ; j<nResults ; j++) {  
				CellLabel = (i+1); // getResult("Label",j);
				MPSnum = (j+1);
				CellArea = TotalCellArea[i];
				MacropinosomeArea = getResult("Area",j);
				TotMPSArea = TotMPSArea + MacropinosomeArea;
				print(summaryFile,windowtitle+ "\t"+CellLabel+"\t"+CellArea+"\t"+MPSnum+"\t"+MacropinosomeArea+"\n");
		  		}
			}

		print("Total LD area for this Image was: "+TotMPSArea);
		print("");
 
	 	saveAs("Results", windowtitle+"Backup");
		roiManager("Save", resultsDir+windowtitle+"_CellAreaROIs.zip");
 		selectWindow("LD");
 		saveAs("tiff", resultsDir+windowtitle+"_LD_THRESH.tif");  
 		close;
		selectWindow("cellmask");
		saveAs("tiff", resultsDir+windowtitle+"_cellmask.tif");
		while (nImages>0){close();}
		File.close(summaryFile);
	}
}


 
print("");																			//Prints runtime to log window
print("* * * * * * * * * * * * * * * * * ");
print("Batch Completed");
print("Total Runtime was:"+ (getTime()-start)/1000);

selectWindow("Log");																//Selects the log window
saveAs("Text", resultsDir+"Log.txt");												//Saves the log window


title = "Batch Completed";															//Exit message
msg = "Put down that coffee! Your analysis is finished";
waitForUser(title, msg); 


