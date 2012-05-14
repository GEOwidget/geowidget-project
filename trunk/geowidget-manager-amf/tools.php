<?php
/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

	function toLog($title, $str)
	{

		$fname = 'log.txt';

		$fp = fopen($fname,"a");
		fwrite($fp,"\n//-----------------------------------------------------");
		fwrite($fp,"\n//----$title");
		fwrite($fp,"\n//-----------------------------------------------------");

		if( is_array( $str ) ){
			ob_start();
			print_r( $str );
			$str = ob_get_contents();
			ob_end_clean();
		}

		fwrite ( $fp,"\n".$str);
	}

	function removeDirContents($d)
	{
		if(file_exists($d))
		{
			$dirHandle = dir($d);

			while($entry = $dirHandle->read())
			{
				if ($entry != "." && $entry != "..")
				{

					if(is_file($d . DIRECTORY_SEPARATOR . $entry))
					{
						unlink($d . DIRECTORY_SEPARATOR . $entry);
					}
				}
			}

			$dirHandle->close();

		}

	}
  
  function copyDir($src,$dst) {
      $dir = opendir($src);
      @mkdir($dst);
      while(false !== ( $file = readdir($dir)) ) {
          if (( $file != '.' ) && ( $file != '..' )) {
              if ( is_dir($src . '/' . $file) ) {
                  copyDir($src . '/' . $file,$dst . '/' . $file);
              }
              else {
                  copy($src . '/' . $file,$dst . '/' . $file);
              }
          }
      }
      closedir($dir);
  }   

?>