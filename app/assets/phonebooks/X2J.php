<?php

class X2J {
  
  public function xml2json($xml) {
    $array = $this->xml2array($xml);
    return json_encode($array);
  }
  
  public function json2xml($json, $root, $pretty = true) {
    
    $xml = $this->array2xml(json_decode($json, true), $root);
    
    if ($pretty) {
      $dom = new DOMDocument('1.0', 'UTF-8');
      $dom->preserveWhiteSpace = false;
      $dom->formatOutput = true;
      $dom->loadXML($xml);
      $xml = $dom->saveXML();
    }
    
    return $xml;
    
  }
  
  public function xml2array($xml) {
    
    $json = json_encode(simplexml_load_string($xml));
    
    // this is a hacky way of getting around certain xml -> json conversions
    $json = str_replace('"MenuItem":{}', '"MenuItem":[]', $json);
    $json = str_replace('"SoftKeyItem":{}', '"SoftKeyItem":[]', $json);
    $json = str_replace('"DirectoryEntry":{}', '"DirectoryEntry":[]', $json);
    
    $json = str_replace('"Fax":{}', '"Fax":""', $json);
    $json = str_replace('"URL":{}', '"URL":""', $json);
    $json = str_replace('"URI":{}', '"URI":""', $json);
    $json = str_replace('"Name":{}', '"Name":""', $json);
    $json = str_replace('"Email":{}', '"Email":""', $json);
    $json = str_replace('"Address":{}', '"Address":""', $json);
    $json = str_replace('"Position":{}', '"Position":""', $json);
    $json = str_replace('"Telephone":{}', '"Telephone":""', $json);
    
    $array = json_decode($json, true);
    
    if (isset($array['MenuItem']) and $this->isAssoc($array['MenuItem'])) {
      $array['MenuItem'] = array($array['MenuItem']);
    }
    
    if (isset($array['SoftKeyItem']) and $this->isAssoc($array['SoftKeyItem'])) {
      $array['SoftKeyItem'] = array($array['SoftKeyItem']);
    }
    
    if (isset($array['DirectoryEntry']) and $this->isAssoc($array['DirectoryEntry'])) {
      $array['DirectoryEntry'] = array($array['DirectoryEntry']);
    }
    
    return $array;
  }
  
  protected function array2xml($array, $root = 'root', $xml = null) {
    
    if ($xml === null) {
      $xml = new SimpleXMLElement("<$root></$root>");
    }
    
    foreach ($array as $key => $value) {
      if (is_array($value)) {
        if ($this->isAssoc($value)) {
          $this->array2xml($value, $key, $xml->addChild($key, $xml));
        } else {
          if (empty($value)) {
            $xml->addChild($key, null);
          } else {
            foreach ($value as $sub) {
              $child = $xml->addChild($key);
              foreach ($sub as $key2 => $value2) {
                $child->addChild($key2, $value2);
              }
            }
          }
        }
      } else {
        $xml->addChild($key, $value);
      }
    }
    
    return $xml->asXML();
    
  }
  
  protected function isAssoc($array) {
    // if there is at least one string key, $array is considered an associative array
    // (taken from http://stackoverflow.com/a/4254008/1696150)
    if (!is_array($array)) return false;
    return (bool)count(array_filter(array_keys($array), 'is_string'));
  }
    
}
