/*
 * Macro template to process multiple images in a folder
 */

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".dv") suffix

processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	
	//trying to see where the errors are
//	print("Number of files:", list.length);
//	for(i=0; i<list.length; i++){
//		print(list[i]);
//		}
	
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			//print("Current file: ", list[i]);
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	print("Processing: " + input + File.separator + file);
	//print("Saving to: " + output);
    open(input + File.separator + file);
    run("Clear Results");   // First, clear the results table
	title = getTitle();
	//print (title);
	run("Split Channels");
	selectWindow("C2-" + title);
	run("Z Project...", "projection=[Max Intensity]");
	selectWindow("MAX_C2-" + title);
	setAutoThreshold("Default dark");
	run("Analyze Particles...", "size=2-Infinity circularity=0.50-1.00 display exclude clear summarize add");
	//selectWindow("Summary");
	//print(run(Measure));
	
	//print(getResult("Count"));
	if (isOpen("Results")){
		//print(RoiManager.size);
		selectWindow("C1-" + title);
		roiManager("Select", 0)
		run("Crop");
		run("Clear Outside", "stack");
		//close();
		//selectWindow("C1-" + title);
		//run("Duplicate...", "duplicate");
		//run("Gaussian Blur 3D...", "x=2 y=2 z=2");
		setAutoThreshold("Default dark");
		//setThreshold(2800.0000, 1000000000000000000000000000000.0000);
		run("Set Measurements...", "area mean min shape integrated area_fraction stack limit redirect=None decimal=3");
		run("Analyze Particles...", "size=2-Infinity circularity=0.10-1.00 display clear summarize add stack");
		totalArea = 0;
			for (n=0; n < nResults; n++) {
	   			totalArea += getResult("Area",n);// Add the area of the current result to the total
			}
		getVoxelSize(width, height, depth, unit);
		volume = totalArea*depth;
		print("GC Volume:" + volume); //unit is micron^3
		//run("Invert");
		setAutoThreshold("Triangle");
		FCarea = 0;
		for (i=0; i<roiManager("count"); i++){			
			//print (roiManager("index"));
			roiManager("Select", i);
			run("Set Measurements...", "area mean min shape integrated area_fraction stack limit redirect=None decimal=3");
			run("Measure");
			FCarea += getResult("Area");
			}
		FCvolume = FCarea*depth;
		print("FC volume:", FCvolume);
		selectWindow("Log");
		//getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
		//print("Log"+year+"_"+month+1+"_",dayOfMonth, "_", hour , "_",minute;
		//dateandtime = replace(dateandtime, " ", "");
		//print(dateandtime);
		LogOutputPath = output + "/" + "Log.txt";
		//LogOutputPath = ""+ year + "" + month+1 + ""+ dayOfMonth + ""+hour + ""+minute + "_Log.csv";
		//LogOutputPath = "/" + year +"_"+ month+1 +"_"+ dayOfMonth +"_"+ hour +"_"+ minute + "_Log.csv";
		//print(LogOutputPath);
		saveAs("text", LogOutputPath);
		SumWindowName = "Summary of " + "C1-" + title;
		SumOutputPath =  output + "/" + replace(title,".dv","") + "_Summary.csv";
		//print(SumOutputPath);
		selectWindow(SumWindowName);
		saveAs("Results", SumOutputPath);
		run("Close"); 
		ResultsOutputPath = output + "/" + replace(title,".dv","") + "_Results.csv";
		selectWindow("Results");
		saveAs("Results", ResultsOutputPath);
		run("Close"); 
		MaxSumOutputPath = output + "/" + replace(title,".dv","") + "_MaxSum.csv"; 
		selectWindow("Summary");
		saveAs("Results", MaxSumOutputPath);
		run("Close");
		tiffOutputPath = output + "/" + replace(title,".dv","") + "_Cropped.csv";
		selectWindow("C1-" + title); 
		saveAs("tiff", tiffOutputPath);
		//close(input + File.separator + file);
		close("*");
		close("ROI Manager");
		close("Results");
		//selectWindow("Summary");
		
	}
	else{
		//print(title);
		print("GC Volume: N/A");
		print("FC Volume: N/A");
		selectWindow("Log");
		LogOutputPath = output + "/" + "Log.txt";
		saveAs("text", LogOutputPath);
		//SumWindowName = "Summary of " + "C1-" + title;
		//SumOutputPath =  output + "/" + replace(title,".dv","") + "_Summary.csv";
		//saveAs("Results", SumOutputPath); 
		//selectWindow(title + "_MaxSum.c);
		MaxSumOutputPath = output + "/" + replace(title,".dv","") + "_MaxSum.csv"; 
		selectWindow("Summary");
		saveAs("Results", MaxSumOutputPath);
		run("Close");
		//close("*");
		//close("ROI Manager");
		//selectWindow("Summary");
		//run("Close");
		//close("Results");
		continue;
		}
	
}