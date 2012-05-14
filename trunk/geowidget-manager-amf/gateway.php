<?php
/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

	// use included zend framework if available
	set_include_path(get_include_path() . PATH_SEPARATOR . "../../library");

	define("APPLICATION_PATH", dirname(__FILE__));

	require_once 'Zend/Amf/Server.php';
	require_once 'Zend/Mail/Transport/Smtp.php';
	require_once 'vo/CommitDataVO.php';
	require_once 'vo/IconVO.php';
	require_once 'vo/ImageVO.php';
	require_once 'vo/UserVO.php';
	require_once 'vo/metadata/GlobalTemplateVO.php';
	require_once 'vo/metadata/HTMLTemplateMetaVO.php';
	require_once 'vo/metadata/IconGroupMetaVO.php';
	require_once 'vo/metadata/IconMetaVO.php';
	require_once 'vo/metadata/InfoWindowGroupMetaVO.php';
	require_once 'vo/metadata/InfoWindowMetaVO.php';
	require_once 'vo/metadata/InfoWindowTemplateVO.php';
	require_once 'vo/metadata/MetaDataVO.php';
	require_once 'services/CommitService.php';
	require_once 'services/SessionService.php';
	require_once 'services/WidgetService.php';

	require_once 'tools.php';


    // instantiate server
    $server = new Zend_Amf_Server();

    // set production mode to true to suppress debug messages
	$server->setSession();
    $server->setProduction(true);
	// do not use addDirectory, explicitly specify each service class (otherwise causes https://www2.hosted-projects.com/trac/mschiesser/filialfinder/ticket/185)
    // $server->addDirectory(dirname(__FILE__).'/services/');
	$server->setClass('CommitService');
	$server->setClass('SessionService');
	$server->setClass('WidgetService');

	// do class mapping (explizit type in class does NOT work all the time!)
	$server->setClassMap('vo.CommitDataVO','CommitDataVO');
	$server->setClassMap('vo.IconVO','IconVO');
	$server->setClassMap('vo.ImageVO','ImageVO');
	$server->setClassMap('vo.UserVO','UserVO');
	$server->setClassMap('vo.CountryVO','CountryVO');
	$server->setClassMap('vo.metadata.GlobalTemplateVO','GlobalTemplateVO');
	$server->setClassMap('vo.metadata.HTMLTemplateMetaVO','HTMLTemplateMetaVO');
	$server->setClassMap('vo.metadata.IconGroupMetaVO','IconGroupMetaVO');
	$server->setClassMap('vo.metadata.IconMetaVO','IconMetaVO');
	$server->setClassMap('vo.metadata.InfoWindowGroupMetaVO','InfoWindowGroupMetaVO');
	$server->setClassMap('vo.metadata.InfoWindowMetaVO','InfoWindowMetaVO');
	$server->setClassMap('vo.metadata.InfoWindowTemplateVO','InfoWindowTemplateVO');
	$server->setClassMap('vo.metadata.MetaDataVO','MetaDataVO');

    // handle request
    $response = $server->handle();

    echo($response);

?>