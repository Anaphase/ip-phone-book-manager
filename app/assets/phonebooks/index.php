<?php

require 'X2J.php';

require 'Slim/Slim.php';
\Slim\Slim::registerAutoloader();

$app = new \Slim\Slim();
$X2J = new X2J();

$app = new \Slim\Slim(array('debug' => false)); // debug must be false for the custom error handler to work
$res = $app->response();
$res['Content-Type'] = 'application/json; charset=utf-8';

$xml_path = 'data/xml';
$input = file_get_contents('php://input');

function slugify($string) {
  
  $string = strtolower($string);
  $string = preg_replace('/[^\w ]+/', '', $string);
  $string = preg_replace('/ +/', '-', $string);
  
  return $string;
  
}

function validateJSON($json) {
  if (isset($json) and json_decode($json) === null) {
    throw new Exception('Invalid JSON');
  }
}

function validateType($type) {
  
  switch ($type) {
    case 'cisco':
      $url_key = 'URL';
      $name_key = 'Name';
      $menu_root = 'CiscoIPPhoneMenu';
      $directory_root = 'CiscoIPPhoneDirectory';
      break;
    case 'yealink':
      $url_key = 'URI';
      $name_key = 'Prompt';
      $menu_root = 'YealinkIPPhoneTextMenu';
      $directory_root = 'YealinkIPPhoneDirectory';
      break;
    default:
      throw new Exception('Parameter "type" must be "cisco" or "yealink"');
  }
  
  return array($url_key, $name_key, $menu_root, $directory_root);
  
}

function getMenu($type) {
  global $xml_path;
  return file_get_contents("$xml_path/$type/menu.xml");
}

function getDirectory($type, $id) {
  global $xml_path;
  return file_get_contents("$xml_path/$type/directories/$id.xml");
}

function getSettings() {
  return json_decode(file_get_contents("data/settings.json"), true);
}

function putMenu($type, $xml) {
  global $xml_path;
  return file_put_contents("$xml_path/$type/menu.xml", $xml, LOCK_EX);
}

function putDirectory($type, $id, $xml) {
  global $xml_path;
  return file_put_contents("$xml_path/$type/directories/$id.xml", $xml, LOCK_EX);
}

function putSettings($json) {
  return file_put_contents("data/settings.json", $json, LOCK_EX);
}

// custom error handler so we return JSON and not Slim's HTML stacktrace
// NOTE: this handler only fires if Slim's debug option is false
$app->error(function(Exception $e) {
  echo json_encode(array(
    'data' => null
  , 'status_code' => 500
  , 'status_txt'  => $e->getMessage()
  ));
});

// custom 404 page so we return JSON and not Slim's HTML 404
$app->notFound(function() {
  echo json_encode(array(
    'data' => null
  , 'status_code' => 404
  , 'status_txt'  => 'Route not found'
  ));
});




// READ
  
  // MENUS
  $app->get('/:type/menu', function($type) use ($X2J) {
    
    validateType($type);
    
    echo $X2J->xml2json(getMenu($type));
    
  });
  
  $app->get('/:type/menu/menu-item/:id', function($type, $id) use ($X2J) {
    
    list ($url_key, $name_key, $menu_root, $directory_root) = validateType($type);
    
    $menu_array = $X2J->xml2array(getMenu($type));
    
    $selected_menu_item = null;
    
    foreach ($menu_array['MenuItem'] as $menu_item) {
      
      $slug = slugify($menu_item[$name_key]);
      
      if ($slug === $id) {
        $selected_menu_item = $menu_item;
        break;
      }
      
    }
    
    echo json_encode($selected_menu_item);
    
  });
  
  
  // DIRECTORIES
  $app->get('/:type/directory/:id', function($type, $id) use ($X2J) {
    
    validateType($type);
    
    echo $X2J->xml2json(getDirectory($type, $id));
    
  });
  
  $app->get('/:type/directory/:id/title', function($type, $id) use ($X2J) {
    
    validateType($type);
    
    $directory_array = $X2J->xml2array(getDirectory($type, $id));
    
    echo json_encode(array(
      'Title' => $directory_array['Title']
    ));
    
  });
  
  $app->get('/cisco/directory/:id/prompt', function($id) use ($X2J) {
    
    $directory_array = $X2J->xml2array(getDirectory('cisco', $id));
    
    echo json_encode(array(
      'Prompt' => $directory_array['Prompt']
    ));
    
  });
  
  $app->get('/cisco/directory/:id/directory-entry/:entry_id', function($id, $entry_id) use ($X2J) {
    
    $directory_array = $X2J->xml2array(getDirectory('cisco', $id));
    
    if ($entry_id < 0 or count($directory_array['DirectoryEntry']) <= $entry_id) {
      throw new Exception('Invalid DirectoryEntry ID');
    }
    
    echo json_encode($directory_array['DirectoryEntry'][$entry_id]);
    
  });
  
  $app->get('/cisco/directory/:id/soft-key-item/:item_id', function($id, $item_id) use ($X2J) {
    
    $directory_array = $X2J->xml2array(getDirectory('cisco', $id));
    $soft_key_items = $directory_array['SoftKeyItem'];
    
    if ($item_id < 0 or count($soft_key_items) <= $item_id) {
      throw new Exception('Invalid SoftKeyItem ID');
    }
    
    echo json_encode($soft_key_items[$item_id]);
    
  });
  
  $app->get('/yealink/directory/:id/menu-item/:item_id', function($id, $item_id) use ($X2J) {
    
    $directory_array = $X2J->xml2array(getDirectory('yealink', $id));
    $menu_items = $directory_array['MenuItem'];
    
    if ($item_id < 0 or count($menu_items) <= $item_id) {
      throw new Exception('Invalid MenuItem ID');
    }
    
    echo json_encode($menu_items[$item_id]);
    
  });
  
  
  // SETTINGS
  $app->get('/settings', function() use ($X2J) {
    
    $settings_array = getSettings();
    
    echo json_encode($settings_array);
    
  });
  
  $app->get('/settings/:item', function($item) use ($X2J) {
    
    $settings_array = getSettings();
    
    if (isset($settings_array[$item])) {
      echo json_encode($settings_array[$item]);
    } else {
      echo 'null';
    }
    
  });



// CREATE & UPDATE
  
  // MENUS
  
  $app->post('/:type/menu/title', function($type) use ($X2J, $input) {
    
    list ($url_key, $name_key, $menu_root, $directory_root) = validateType($type);
    
    $menu_title = $input;
    $menu_array = $X2J->xml2array(getMenu($type));
    
    $menu_array['Title'] = $menu_title;
    
    $menu_xml = $X2J->json2xml(json_encode($menu_array), $menu_root);
    
    putMenu($type, $menu_xml);
    
    echo $X2J->xml2json(getMenu($type));
    
  });
  
  $app->post('/cisco/menu/prompt', function() use ($X2J, $input) {
    
    list ($url_key, $name_key, $menu_root, $directory_root) = validateType('cisco');
    
    $menu_prompt = $input;
    $menu_array = $X2J->xml2array(getMenu('cisco'));
    
    $menu_array['Prompt'] = $menu_prompt;
    
    $menu_xml = $X2J->json2xml(json_encode($menu_array), $menu_root);
    
    putMenu('cisco', $menu_xml);
    
    echo $X2J->xml2json(getMenu('cisco'));
    
  });
  
  
  // DIRECTORIES
  $app->post('/:type/directory/:id', function($type, $id) use ($X2J, $input) {
    
    validateJSON($input);
    
    list ($url_key, $name_key, $menu_root, $directory_root) = validateType($type);
    
    $directory_json = json_decode($input, true);
    $slug = slugify($directory_json['Title']);
    
    $settings = getSettings();
    
    // create the directory
    $directory_array = null;
    
    switch ($type) {
      case 'cisco':
        
        $directory_array = array(
          'Title' => $directory_json['Title']
        , 'Prompt' => $directory_json['Prompt']
        , 'DirectoryEntry' => array()
        , 'SoftKeyItem' => array()
        );
        
        foreach ($directory_json['DirectoryEntry'] as $directory_entry) {
          $directory_array['DirectoryEntry'][] = array(
            'Name' => $directory_entry['Name']
          , 'Telephone' => $directory_entry['Telephone']
          , 'Fax' => $directory_entry['Fax']
          , 'Address' => $directory_entry['Address']
          , 'Email' => $directory_entry['Email']
          );
        }
        
        foreach ($directory_json['SoftKeyItem'] as $soft_key_item) {
          $directory_array['SoftKeyItem'][] = array(
            'Name' => $soft_key_item['Name']
          , 'URL' => $soft_key_item['URL']
          , 'Position' => $soft_key_item['Position']
          );
        }
        
        break;
      
      case 'yealink':
        
        $directory_array = array(
          'Title' => $directory_json['Title']
        , 'MenuItem' => array()
        );
        
        foreach ($directory_json['MenuItem'] as $menu_item) {
          $directory_array['MenuItem'][] = array(
            'Prompt' => $menu_item['Prompt']
          , 'URI' => $menu_item['URI']
          );
        }
        
        break;
    }
    
    $directory_xml = $X2J->json2xml(json_encode($directory_array), $directory_root);
    
    // update menu
    $menu_array = $X2J->xml2array(getMenu($type));
    
    switch ($type) {
      case 'cisco':
        
        $menu_array['MenuItem'][] = array(
          'Name' => $directory_json['Title']
        , 'URL' => $settings['menu_address'] . "/directories/$slug.xml"
        );
        
        break;
      
      case 'yealink':
        
        $menu_array['MenuItem'][] = array(
          'Prompt' => $directory_json['Title']
        , 'URI' => $settings['menu_address'] . "/directories/$slug.xml"
        );
        
        break;
    }
    
    $menu_xml = $X2J->json2xml(json_encode($menu_array), $menu_root);
    
    // write directory files
    putDirectory($type, $slug, $directory_xml);
    
    // write menu files
    putMenu($type, $menu_xml);
    
    echo $X2J->xml2json(getDirectory($type, $slug));
    
  });
  
  $app->post('/:type/directory/:id/title', function($type, $id) use ($X2J, $input, $xml_path) {
    
    list ($url_key, $name_key, $menu_root, $directory_root) = validateType($type);
    
    $directory_title = $input;
    $new_slug = slugify($directory_title);
    
    // update the directory
    $directory_array = $X2J->xml2array(getDirectory($type, $id));
    $directory_array['Title'] = $directory_title;
    $directory_xml = $X2J->json2xml(json_encode($directory_array), $directory_root);
    
    // update the menu
    $menu_array = $X2J->xml2array(getMenu($type));
    foreach ($menu_array['MenuItem'] as &$menu_item) {
      $old_slug = slugify($menu_item[$name_key]);
      if ($old_slug === $id) {
        $menu_item[$name_key] = $directory_title;
        $menu_item[$url_key] = str_replace($old_slug, $new_slug, $menu_item[$url_key]);
        break;
      }
    }
    $menu_xml = $X2J->json2xml(json_encode($menu_array), $menu_root);
    
    // write directory files
    unlink("$xml_path/$type/directories/$id.xml");
    putDirectory($type, $new_slug, $directory_xml);
    
    // write menu files
    putMenu($type, $menu_xml);
    
    echo $X2J->xml2json(getDirectory($type, $new_slug));
    
  });
  
  $app->post('/cisco/directory/:id/prompt', function($id) use ($X2J, $input) {
    
    list ($url_key, $name_key, $menu_root, $directory_root) = validateType('cisco');
    
    $directory_prompt = $input;
    $directory_array = $X2J->xml2array(getDirectory('cisco', $id));
    
    $directory_array['Prompt'] = $directory_prompt;
    
    $directory_xml = $X2J->json2xml(json_encode($directory_array), $directory_root);
    
    putDirectory('cisco', $id, $directory_xml);
    
    echo $X2J->xml2json(getDirectory('cisco', $id));
    
  });
  
  $app->post('/cisco/directory/:id/directory-entry(/:entry_id)', function($id, $entry_id = null) use ($X2J, $input) {
    
    validateJSON($input);
    
    list ($url_key, $name_key, $menu_root, $directory_root) = validateType('cisco');
    
    $new_directory_entry = json_decode($input, true);
    $directory_array = $X2J->xml2array(getDirectory('cisco', $id));
    
    if ($entry_id < 0) {
      throw new Exception('Invalid DirectoryEntry ID');
    } else if (!isset($entry_id) or $entry_id > count($directory_array['DirectoryEntry'])) {
      $entry_id = count($directory_array['DirectoryEntry']);
    }
    
    $directory_array['DirectoryEntry'][$entry_id] = array(
      'Name' => $new_directory_entry['Name']
    , 'Telephone' => $new_directory_entry['Telephone']
    , 'Fax' => $new_directory_entry['Fax']
    , 'Address' => $new_directory_entry['Address']
    , 'Email' => $new_directory_entry['Email']
    );
    
    $directory_xml = $X2J->json2xml(json_encode($directory_array), $directory_root);
    
    putDirectory('cisco', $id, $directory_xml);
    
    echo json_encode($directory_array['DirectoryEntry'][$entry_id]);
    
  });
  
  $app->post('/cisco/directory/:id/soft-key-item(/:item_id)', function($id, $item_id = null) use ($X2J, $input) {
    
    validateJSON($input);
    
    list ($url_key, $name_key, $menu_root, $directory_root) = validateType('cisco');
    
    $new_soft_key_item = json_decode($input, true);
    $directory_array = $X2J->xml2array(getDirectory('cisco', $id));
    
    if ($item_id < 0) {
      throw new Exception('Invalid SoftKeyItem ID');
    } else if (!isset($item_id) or $item_id > count($directory_array['SoftKeyItem'])) {
      $item_id = count($directory_array['SoftKeyItem']);
    }
    
    $directory_array['SoftKeyItem'][$item_id] = array(
      'Name' => $new_soft_key_item['Name']
    , 'URL' => $new_soft_key_item['URL']
    , 'Position' => $new_soft_key_item['Position']
    );
    
    $directory_xml = $X2J->json2xml(json_encode($directory_array), $directory_root);
    
    putDirectory('cisco', $id, $directory_xml);
    
    echo json_encode($directory_array['SoftKeyItem'][$item_id]);
    
  });
  
  $app->post('/yealink/directory/:id/menu-item(/:item_id)', function($id, $item_id = null) use ($X2J, $input) {
    
    validateJSON($input);
    
    list ($url_key, $name_key, $menu_root, $directory_root) = validateType('yealink');
    
    $new_menu_item = json_decode($input, true);
    $directory_array = $X2J->xml2array(getDirectory('yealink', $id));
    
    if ($item_id < 0) {
      throw new Exception('Invalid MenuItem ID');
    } else if (!isset($item_id) or $item_id > count($directory_array['MenuItem'])) {
      $item_id = count($directory_array['MenuItem']);
    }
    
    $directory_array['MenuItem'][$item_id] = array(
      'Prompt' => $new_menu_item['Prompt']
    , 'URI' => $new_menu_item['URI']
    );
    
    $directory_xml = $X2J->json2xml(json_encode($directory_array), $directory_root);
    
    putDirectory('yealink', $id, $directory_xml);
    
    echo json_encode($directory_array['MenuItem'][$item_id]);
    
  });
  
  
  // SETTINGS
  $app->post('/settings', function() use ($X2J, $input, $xml_path) {
    
    validateJSON($input);
    
    $new_settings_json = $input;
    $new_settings_array = json_decode($new_settings_json, true);
    $old_settings_array = getSettings();
    
    $new_menu_address = $new_settings_array['menu_address'];
    $old_menu_address = $old_settings_array['menu_address'];
    
    // update the menu address in all xml files
    if ($new_menu_address !== $old_menu_address) {
      $files = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($xml_path), RecursiveIteratorIterator::LEAVES_ONLY);
      
      foreach ($files as $name => $file) {
        if (is_dir($file)) continue;
        file_put_contents($file, str_replace($old_menu_address, $new_menu_address, file_get_contents($file)));
      }
      
    }
    
    putSettings($new_settings_json);
    
    echo json_encode(getSettings());
    
  });



// DELETE
  
  // MENUS
  // (not supported)
  
  
  // DIRECTORIES
  $app->delete('/:type/directory/:id', function($type, $id) use ($X2J, $xml_path) {
    
    list ($url_key, $name_key, $menu_root, $directory_root) = validateType($type);
    
    // update the directory
    // (nothing to do here since we'll just delete the file below)
    
    // update the menu
    $index = 0;
    $menu_array = $X2J->xml2array(getMenu($type));
    foreach ($menu_array['MenuItem'] as &$menu_item) {
      $slug = slugify($menu_item[$name_key]);
      if ($slug === $id) {
        unset($menu_array['MenuItem'][$index]);
        break;
      }
      $index++;
    }
    $menu_array['MenuItem'] = array_values($menu_array['MenuItem']);
    
    $menu_xml = $X2J->json2xml(json_encode($menu_array), $menu_root);
    
    // write directory files
    unlink("$xml_path/$type/directories/$id.xml");
    
    // write menu files
    putMenu($type, $menu_xml);
    
  });
  
  $app->delete('/cisco/directory/:id/directory-entry(/:entry_id)', function($id, $entry_id = null) use ($X2J) {
    
    list ($url_key, $name_key, $menu_root, $directory_root) = validateType('cisco');
    
    $directory_array = $X2J->xml2array(getDirectory('cisco', $id));
    
    if (!isset($entry_id) or $entry_id < 0 or $entry_id >= count($directory_array['DirectoryEntry'])) {
      throw new Exception('Invalid DirectoryEntry ID');
    }
    
    unset($directory_array['DirectoryEntry'][$entry_id]);
    
    $directory_array['DirectoryEntry'] = array_values($directory_array['DirectoryEntry']);
    
    $directory_xml = $X2J->json2xml(json_encode($directory_array), $directory_root);
    
    putDirectory('cisco', $id, $directory_xml);
    
  });
  
  $app->delete('/cisco/directory/:id/soft-key-item(/:item_id)', function($id, $item_id = null) use ($X2J) {
    
    list ($url_key, $name_key, $menu_root, $directory_root) = validateType('cisco');
    
    $directory_array = $X2J->xml2array(getDirectory('cisco', $id));
    
    if (!isset($item_id) or $item_id < 0 or $item_id >= count($directory_array['SoftKeyItem'])) {
      throw new Exception('Invalid SoftKeyItem ID');
    }
    
    unset($directory_array['SoftKeyItem'][$item_id]);
    
    $directory_array['SoftKeyItem'] = array_values($directory_array['SoftKeyItem']);
    
    $directory_xml = $X2J->json2xml(json_encode($directory_array), $directory_root);
    
    putDirectory('cisco', $id, $directory_xml);
    
  });
  
  $app->delete('/yealink/directory/:id/menu-item(/:item_id)', function($id, $item_id = null) use ($X2J) {
    
    list ($url_key, $name_key, $menu_root, $directory_root) = validateType('yealink');
    
    $directory_array = $X2J->xml2array(getDirectory('yealink', $id));
    
    if (!isset($item_id) or $item_id < 0 or $item_id >= count($directory_array['MenuItem'])) {
      throw new Exception('Invalid MenuItem ID');
    }
    
    unset($directory_array['MenuItem'][$item_id]);
    
    $directory_array['MenuItem'] = array_values($directory_array['MenuItem']);
    
    $directory_xml = $X2J->json2xml(json_encode($directory_array), $directory_root);
    
    putDirectory('yealink', $id, $directory_xml);
    
  });

$app->run();
