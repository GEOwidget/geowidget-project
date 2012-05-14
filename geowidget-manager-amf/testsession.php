<?php
/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

	require_once('Zend/Session/Namespace.php');
	require_once('Zend/Locale.php');

	$session = new Zend_Session_Namespace();
	$session->email = 'testuser';
	$session->isAuth = true;
	$session->user = array('folder' => '/widgets/K8uib7Bu8p4=', 'first_name' => 'test', 'last_name' => 'Tester', 'gender' => 'm', 'email_address' => $session->email, 'website_address' => 'http://www.hello.com');

	$sessionLocale = new Zend_Session_Namespace('Locale');
	$sessionLocale->locale = new Zend_Locale();
	$sessionLocale->numberOfLocations = 5;

	header('Location: /flash/geowidget.html');



?>