<?php
/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
require_once 'WidgetService.php';
require_once 'SessionService.php';
require_once 'vo/CommitDataVO.php';
require_once 'Zend/Mail.php';
require_once 'Zend/View.php';

class CommitService {

	private function getPrice($locations) {
		switch($locations) {
			case 0:
				return 0;
			case ($locations <= 10):
				return 0.89;
			case ($locations <= 100):
				return 0.69;
			case ($locations <= 500):
				return 0.59;
			case ($locations <= 1000):
				return 0.49;
			case ($locations <= 5000):
				return 0.39;
			case ($locations <= 10000):
				return 0.29;
			default:
				return 0.19;
		}
	}

	public function getCommitData($locations) {
		$commitData = new CommitDataVO();
		$commitData->numberLocations = $locations;
		$commitData->pricePerLocation = $this->getPrice($locations);
		$commitData->pricePerMonth = $commitData->pricePerLocation * $locations;
		$commitData->pricePer3Months = $commitData->pricePerMonth * 3;
		$commitData->pricePer6Months = $commitData->pricePerMonth * 6;
		$commitData->pricePerYear = $commitData->pricePerMonth * 12;
		return $commitData;
	}

	public function commit($actionCode, $locations) {
		SessionService::ensureLogin();
		$sessionService = new SessionService();
		// send email with commit data and actioncode to info@geowidget.de
        $mail = new Zend_Mail();
        $mail->setFrom('info@geowidget.de', 'GEOwidget')
			->setSubject('Commit data from GEOwidget')
			->addTo('info@geowidget.de');
        $view = new Zend_View();
        $view->setScriptPath(APPLICATION_PATH . '/mail_templates/');
		$commitData = (array) $this->getCommitData($locations);
		foreach($commitData as $key => $val) {
			if($key !== '_explicitType') {
				$view->assign($key, $val);
			}
		}
		$view->assign('actionCode', $actionCode);
		$view->assign('user', $sessionService->getUser());


        $mail->setBodyHtml($view->render('commit_geo.phtml'));
        $mail->send();

	}

}
?>