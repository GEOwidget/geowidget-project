<?php
/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
require_once('Zend/Session/Namespace.php');
require_once('Zend/Auth.php');
require_once('Zend/Locale.php');
require_once('vo/UserVO.php');
require_once('vo/CountryVO.php');
require_once('services/WidgetService.php');


class SessionService {

    function SessionService() {
    }

	public static function ensureLogin() {
		$session = new Zend_Session_Namespace();
		if (!isset($session->isAuth) || $session->isAuth !== true) {
			throw new Exception('You are not permitted to access this page! Please log in again.');
		}
	}

	public function logout() {
		$session = new Zend_Session_Namespace();
		$session->email = "";
		$session->isAuth = false;
		$auth = Zend_Auth::getInstance();
		$auth->clearIdentity();
	}

	public function getUser() {
		SessionService::ensureLogin();
		$session = new Zend_Session_Namespace();
		$localeSession = new Zend_Session_Namespace('Locale');
		$user = new UserVO();
		$user->gender = $session->user['gender'];
		$user->email = $session->user['email_address'];
		$user->website = $session->user['website_address'];
		$user->firstName = $session->user['first_name'];
		$user->lastName = $session->user['last_name'];
		$user->numberOfLocations = $localeSession->numberOfLocations;
		$user->langCode = $localeSession->locale->getLanguage();
		$user->countryCode = $localeSession->locale->getRegion();
		if(!$user->countryCode) {
			switch($user->langCode) {
				case 'en':
					$user->countryCode = 'US';
				break;
				case 'de':
					$user->countryCode = 'DE';
				break;
			}
		}
		$widgetService = new WidgetService();
		$user->widgetSaved = $widgetService->envDoesExist('test');
    $user->folder = $widgetService->getUserFolder();
		return $user;
	}

	public function getCountryList()
	{
		$result = array();

		$localeSession = new Zend_Session_Namespace('Locale');

		$priorityCountryList[] = 'US';
		$priorityCountryList[] = 'GB';
		$priorityCountryList[] = 'DE';
		$priorityCountryList[] = 'ES';
		$priorityCountryList[] = 'AT';
		$priorityCountryList[] = 'CH';

		$zend_locale = $localeSession->locale;

		$countryList = $zend_locale->getTranslationList('Territory', $zend_locale, 2);

		foreach($priorityCountryList as $countryCode)
		{

			if($countryList[$countryCode])
			{
				$countryName = $countryList[$countryCode];

				$country = new CountryVO();
				$country->code = $countryCode;
				$country->name = $countryName;

				$result[] = $country;

				unset($countryList[$countryCode]);
			}

		}

		$country = new CountryVO();
		$country->name = '';

		$result[] = $country;

		foreach($countryList as $countryCode=>$countryName)
		{
			$country = new CountryVO();
			$country->code = $countryCode;
			$country->name = $countryName;

			$result[] = $country;
		}

		return $result;
	}

	public function sendFeedback($userName, $userEmail, $feedback, $sendCopy, $url)
	{

		$mail = new Zend_Mail();
		$mail->setFrom('info@geowidget.de', 'GEOwidget')
			->setSubject('Geowidget New Feedback')
			->addTo('info@geowidget.de');

		if($sendCopy)
		{
			$mail->addTo($userEmail);
		}

		$view = new Zend_View();
		$view->setScriptPath(APPLICATION_PATH . '/mail_templates/');
		$view->assign('userName', $userName);
		$view->assign('userEmail', $userEmail);
		$view->assign('feedback', $feedback);
		$view->assign('url', $url);

		$mail->setBodyHtml($view->render('feedback.phtml'));

		$mail->send();

	}

}
?>