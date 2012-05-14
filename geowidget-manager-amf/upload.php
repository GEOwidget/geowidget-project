<?php
/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

	include_once('tools.php');

    $userfile = $_FILES['Filedata']['tmp_name'];

    //original file name
    $userfile_name = $_FILES['Filedata']['name'];
    //$userfile_error is any error encountered
    $userfile_error = $_FILES[$userfile]['error'];

    $userfile_is_image = false;

    $ext = substr(strrchr($userfile_name, '.'), 1);
    $ext = strtoupper($ext);

    if($ext == 'PNG' ||
    	$ext == 'JPG' ||
    	$ext == 'JPEG' ||
    	$ext == 'GIF')
	{
		$userfile_is_image = true;
	}

    header("Content-type: text/xml");
    $status = "<?xml version=\"1.0\" ?>\n";

    if($userfile == "") {
        $status .= '<status code="1" message="File is not uploaded" />';
    }
    else{
        if($userfile_error > 0){
            $status .= '<status code="'.$userfile_error.'" message="';
            switch($userfile_error){
            case 1: $status .= 'file size is over upload size limit"/>'; break;
            case 2: $status .= 'file size is over file size limit"/>'; break;
            case 3: $status .= 'file size is partially uploaded"/>';break;
            case 4: $status .= 'no file uploaded"/>';break;
            }

        }
        else{

			if(is_uploaded_file($userfile)){

           		$temp_file_name = uniqid($userfile_name);

                if(!move_uploaded_file($userfile, dirname(__FILE__) . '/tmp/' . $temp_file_name)){
                   $status .= '<status code="1" message="Could not move file to destination directory" />';
                }else{

                    $status .= '<status code="0" message="http://'.$_SERVER['SERVER_NAME'].'/amf/tmp/'.$temp_file_name.'" temp_file_name="'.$temp_file_name.'" />';
                }

            }else{
                $status .= '<status code="1" message="Possible file upload attack"/>';
            }
        }
    }

    echo $status;

?>