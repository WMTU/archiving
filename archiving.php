<?php
//Run me every hour for best results

//Config variables
//Server address
$streamserver = "localhost";
//Server port
$streamport = "8000";
//Stream mount point
$streammount = "/relay";
//Where the archives are to be located
$archiveroot = "/var/www/archives/";



//Don't touch nothin after this, please
$times = fopen("./times", "r");
$day = date("D");
$hour = date("G");
$detailtime = date("Y-m-d\TH-i-s");
$numbers = array(0=>12,1=>2);

//Check to make sure that we have the times an durations file
if(!$times){die("Couldn't open times file!");}

//Make the archive sub directory if needed
if(!is_dir($archiveroot.$day)){
	if(!mkdir($archiveroot.$day)){
		die("Couldn't make needed directory!");
	}
}

//We should clear out the current day folder so that we don't build up to much music
if($hour == "0"){
	$files = glob($archiveroot.$day.'/*'); // get all file names
	foreach($files as $file){ // iterate files
  		if(is_file($file))
			unlink($file); // delete file
	}
}

//Start looping through the times files to get the current times and duraations for that specific time
while(!feof($times)){
	//Get a line and cut off white space
	$line = fgets($times);
	$line = trim($line);
	//Make sure were not reading a comment
	if(substr($line, 0, 2) != "//"){
		//Split the line csv style
		$numbers = explode(",",$line);
		//The first element should be the time to start in military time and just the hour so 0-24
		$start = $numbers[0];
		//The second element should be the duration to record for in hours
		$duration = $numbers[1] * 60 * 60;
		//If its currently and hour we are supposed record; kick it off
		if($start == $hour){
			//First form the command based on the given parameters
			$command = '/usr/bin/avconv -i http://'.$streamserver.':'.$streamport.''.$streammount.' -f mp3 -t '.$duration.':00 -acodec copy  '.$archiveroot.''.$day.'/'.$detailtime.'.mp3> /dev/null 2>/dev/null &';
			//Execute that beeotch
			system($command);
			//And we're done
			break;
		}
	}
}

fclose($times);
?>
