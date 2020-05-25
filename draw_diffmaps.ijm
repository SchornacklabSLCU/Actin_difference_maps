// extract_frames_and_pxiels.ijm

setBatchMode(true);
inputDir = getArgument();

fileList = getFileList(inputDir);

for(i = 1; i <= fileList.length; i++) {
  fileName = fileList[i];
  filePath = inputDir + File.separator + fileName;
  run("Text Image... ", "open=" + filePath);
  fileBase = File.nameWithoutExtension;
  run("Fire");
  saveAs("Jpeg", inputDir + File.separator + fileBase + ".jpg");
  close();
}

setBatchMode(false);
