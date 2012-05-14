<?php
/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
require_once 'SessionService.php';
require_once 'Zend/Json.php';

define("WIDGET_DIR", '/widgets');

define("APP_URL", 'http://'.$_SERVER['SERVER_NAME'] . '/geowidget-js/index.html');
// Example: http://www.geowidget.de/geowidget-js/index.html
define("USER_URL", 'http://'.$_SERVER['SERVER_NAME']);
// SERVER_NAME: The name of the server host under which the current script is executing.
// If the script is running on a virtual host, this will be the value defined for that virtual host.
// Example: http://www.geowidget.de
define("USER_DIR", realpath($_SERVER['DOCUMENT_ROOT']));

// DOCUMENT_ROOT: The document root directory under which the current script is executing,
// as defined in the server's configuration file.
// Example: /var/www/html/public

class WidgetService {


	function WidgetService() {
	}

	private function encrypt($value) {

		$key = 'dfqtwt1238dqged123';

		$iv_size = mcrypt_get_iv_size(MCRYPT_BLOWFISH, MCRYPT_MODE_ECB);
		$iv = mcrypt_create_iv($iv_size, MCRYPT_RAND);

		$result = mcrypt_encrypt(MCRYPT_BLOWFISH, $key, $value, MCRYPT_MODE_ECB, $iv);
		$result = base64_encode($result);
		$result = str_replace('/', '-', $result);

		return $result;

	}

	private function createWidget($environment, $config, $templates, $widgetCode=null) {
		$widgetDir = USER_DIR.WIDGET_DIR.'/'.$this->createFolder($environment);

		// ensure folders for metadata exists
		if(!file_exists($widgetDir.'/templates'))
			mkdir($widgetDir.'/templates',0755,true);

		if($widgetCode!=null)
		{
			$res = file_put_contents($widgetDir.'/example.html', $widgetCode);
		}
		file_put_contents($widgetDir.'/config.json',$config);

		for( $count = 0 ; $count < sizeof($templates); $count++ )
		{
			// Extract filename
			file_put_contents($widgetDir. str_replace('{root}', '', $templates[$count][0]), $this->createTemplate(
				array('label'=>$templates[$count][1], 'html'=>$templates[$count][2])));
		}
    
    // copy body templates if they exist in the test folder (as the manager does not know about them)
    // this hack was added to manage the ias example
    // copyDir(USER_DIR.$this->getUserFolder().'/test/bodyTemplates', $widgetDir);

	}

	private function createTemplate($template) {
		return '<div class="infowindow">' . "\n" . '<span class="title">' . $template['label'] . "</span>\n" . $template['html'] . "\n</div>";
	}

	private function createWidgetCode($folder, $config) {
		//file_put_contents(dirname(__FILE__).'/.log', __METHOD__.':'.print_r($config,true), FILE_APPEND);
		$url = APP_URL;
		$widgetWidth = $config['widgetWidth'];
		$widgetHeight = $config['widgetHeight'];
		$userUrl = USER_URL.WIDGET_DIR.'/'.$folder;
		ob_start();
		include 'widgetTemplateJS.php';
		$widgetCode = ob_get_contents();
		ob_end_clean();
		return $widgetCode;
	}

	private function createFolder($environment) {

		$folder = $this->getFolder($environment);

		$widgetDir = USER_DIR.WIDGET_DIR.'/'.$folder;

		if(!file_exists($widgetDir))
		{
			mkdir($widgetDir, 0755, true);
		}

		return $folder;
	}
	
	private function existsOldEnvironment($environment) {
		$session = new Zend_Session_Namespace();
		$userEmail = $session->email;
		return file_exists( USER_DIR . WIDGET_DIR . '/' . $userEmail . '/' . $environment . '/config.json' );
	}

  public function getUserFolder() {
    $session = new Zend_Session_Namespace();
    $userEmail = $session->email;

    $userEmail_encrypted = $this->encrypt($userEmail);

    if($this->existsOldEnvironment('test') )
    {
      $folder = $userEmail;
    }
    else
    {
      $folder = $userEmail_encrypted;
    }

    return WIDGET_DIR.'/'.$folder;
  }

	private function getFolder($environment) {
		$session = new Zend_Session_Namespace();
		$userEmail = $session->email;

		$userEmail_encrypted = $this->encrypt($userEmail);

		if($this->existsOldEnvironment($environment) )
		{
			$folder = $userEmail . '/' . $environment;
		}
		else
		{
			$folder = $userEmail_encrypted . '/' . $environment;
		}

		return $folder;
	}

	public function getWidgetExampleUrl($environment) {
		return $this->getWidgetUrl($environment).'/example.html';
	}

	public function getWidgetUrl($environment) {
		$folder = $this->getFolder($environment);
		$userUrl = USER_URL.WIDGET_DIR.'/'.$folder;
		return $userUrl;
	}

	public function saveWidget($environment, $templates, $encodedConfig) {
		SessionService::ensureLogin();
		$config = Zend_Json::decode($encodedConfig);

		// remove old config if it exists
		if($this->existsOldEnvironment($environment)) {
			$this->removeWidget(array($environment));
		}
		
		//file_put_contents(dirname(__FILE__).'/.log', print_r($config,true));
		$folder = $this->createFolder($environment);

		$widgetCode = $this->createWidgetCode($folder, $config);
		//$encodedConfig = str_replace("{","{\n",$encodedConfig);
		$this->createWidget($environment, $encodedConfig, $templates, $widgetCode);
		return array('code' => $widgetCode, 'url' => $this->getWidgetExampleUrl($environment));
	}
  
  public function saveImages($environment, $icons, $images) {
    $widgetDir = USER_DIR.WIDGET_DIR.'/'.$this->createFolder($environment);

    if(!file_exists($widgetDir.'/icons'))
      mkdir($widgetDir.'/icons',0755,true);
    if(!file_exists($widgetDir.'/images'))
      mkdir($widgetDir.'/images',0755,true);

    for( $count = 0 ; $count < sizeof($icons); $count++ )
    {
      // Extract filename
      $icons[$count][0] = basename($icons[$count][0]);
      file_put_contents($widgetDir.'/icons/'.$icons[$count][0], $icons[$count][1]);
    }

    for( $count = 0 ; $count < sizeof($images); $count++ )
    {
      // Extract filename
      $images[$count][0] = basename($images[$count][0]);
      file_put_contents($widgetDir.'/images/'.$images[$count][0], $images[$count][1]);
    }
    
  }

	public function loadWidget() {
		SessionService::ensureLogin();
		$folder = $this->getFolder('test');
		$widgetDir = USER_DIR.WIDGET_DIR.'/'.$folder;
		$content = file_get_contents($widgetDir.'/config.json');
		if($content==FALSE) {
			$content = "undefined";
		}

		$widgetUrl = WIDGET_DIR . '/' . $folder;

		return array('json' => $content, 'widgetUrl' => $widgetUrl,
		    'demoUrl' => $this->getWidgetExampleUrl('test') );
	}

	public function removeWidget($environments) {

		SessionService::ensureLogin();

		foreach($environments as $environment)
		{
			$folder = $this->getFolder($environment);
			$widgetDir = USER_DIR.WIDGET_DIR.'/'.$folder;

			if(file_exists($widgetDir))
			{
				if(file_exists($widgetDir.'/icons'))
				{
					removeDirContents($widgetDir.'/icons');
					rmdir($widgetDir.'/icons');
				}

				if(file_exists($widgetDir.'/images'))
				{
					removeDirContents($widgetDir.'/images');
					rmdir($widgetDir.'/images');
				}

				if(file_exists($widgetDir.'/templates'))
				{
					removeDirContents($widgetDir.'/templates');
					rmdir($widgetDir.'/templates');
				}

				if(file_exists($widgetDir))
				{
					removeDirContents($widgetDir);
					rmdir($widgetDir);
				}
			}
		}
	}

	public function envDoesExist($environment) {
		SessionService::ensureLogin();
		$folder = $this->getFolder($environment);
		$widgetDir = USER_DIR.WIDGET_DIR.'/'.$folder;
		return file_exists($widgetDir.'/config.json');
	}


}
?>