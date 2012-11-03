<?php

/**
 * PageRank Lookup (Based on Google Toolbar for Internet Explorer)
 *
 * @copyright   2011 HM2K <hm2k@php.net>
 * @link        http://pagerank.phurix.net/
 * @author      James Wade <hm2k@php.net>
 * @version     $Revision: 1.5 $
 * @require     PHP 4.3.0 (file_get_contents)
 * @updated		06/10/11
 */

class PageRank {

	/**
	 * @var string	$host	The Google hostname for PageRank
	*/
	var $host='toolbarqueries.google.com';
  var $pagerank;
	/**
	 * Returns the PageRank of a URL
	 *
	 * @param string  $q		The query/URL
	 * @param string  $context	A stream_context_create() context resource (optional).
	 *
	 * @return string
	 */
	function PageRank ($q,$context=NULL) {
		$ch=$this->checksum($this->makehash($q));
		$url='http://%s/tbr?client=navclient-auto&ch=%s&features=Rank&q=info:%s';
		$url=sprintf($url,$this->host,$ch,$q);
		$this->pagerank = file_get_contents($url,false,$context);
	}

	// Convert a string to a 32-bit integer
	function strtonum($str, $check, $magic) {
		$int32unit = 4294967296; // 2^32
		$length = strlen($str);
		for ($i = 0; $i < $length; $i++) {
			$check *= $magic; 	
			/* If the float is beyond the boundaries of integer (usually +/- 2.15e+9 = 2^31), 
			 *	the result of converting to integer is undefined.
			 *	@see http://www.php.net/manual/en/language.types.integer.php
			*/
			if ($check >= $int32unit) {
				$check = ($check - $int32unit * (int) ($check / $int32unit));
				//if the check less than -2^31
				$check = ($check < -2147483648) ? ($check + $int32unit) : $check;
			}
			$check += ord($str{$i}); 
		}
		return $check;
	}

	// Genearate a hash for query
	function makehash($string) {
		$check1 = $this->strtonum($string, 0x1505, 0x21);
		$check2 = $this->strtonum($string, 0, 0x1003f);
		$check1 >>= 2; 	
		$check1 = (($check1 >> 4) & 0x3ffffc0 ) | ($check1 & 0x3f);
		$check1 = (($check1 >> 4) & 0x3ffc00 ) | ($check1 & 0x3ff);
		$check1 = (($check1 >> 4) & 0x3c000 ) | ($check1 & 0x3fff);	
		$t1 = (((($check1 & 0x3c0) << 4) | ($check1 & 0x3c)) <<2 ) | ($check2 & 0xf0f);
		$t2 = (((($check1 & 0xffffc000) << 4) | ($check1 & 0x3c00)) << 0xa) | ($check2 & 0xf0f0000);
		return ($t1 | $t2);
	}

	// Genearate a checksum for the hash string
	function checksum($hashnum) {
		$checkbyte = 0;
		$flag = 0;
		$hashstr = sprintf('%u', $hashnum) ;
		$length = strlen($hashstr);
		for ($i = $length - 1;  $i >= 0;  $i --) {
			$re = $hashstr{$i};
			if (1 === ($flag % 2)) {              
				$re += $re;     
				$re = (int)($re / 10) + ($re % 10);
			}
			$checkbyte += $re;
			$flag ++;	
		}
		$checkbyte %= 10;
		if (0 !== $checkbyte) {
			$checkbyte = 10 - $checkbyte;
			if (1 === ($flag % 2) ) {
				if (1 === ($checkbyte % 2)) {
					$checkbyte += 9;
				}
				$checkbyte >>= 1;
			}
		}
		return '7'.$checkbyte.$hashstr;
	}
}//eof