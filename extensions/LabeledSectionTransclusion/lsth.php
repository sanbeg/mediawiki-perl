<?php
if ( ! defined( 'MEDIAWIKI' ) )
	die();

/**#@+ 
 *
 * A parser extension that further extends labeled section transclusion,
 * adding a functions, #lsth for transcluding marked sections of text,
 * based on code by Algorithmix.
 *
 * @package MediaWiki
 * @subpackage Extensions
 *
 * @link http://www.mediawiki.org/wiki/Labeled_Section_Transclusion Documentation
 *
 * @author Steve Sanbeg
 * @copyright Copyright © 2006, Steve Sanbeg
 * @license http://www.gnu.org/copyleft/gpl.html GNU General Public License 2.0 or later
 */

##
# Standard initialisation code
##

$wgExtensionFunctions[]="wfLabeledSectionTransclusionHeading";
$wgHooks['LanguageGetMagic'][] = 'wfLabeledSectionTransclusionHeadingMagic';
$wgParserTestFiles[] = dirname( __FILE__ ) . "/lsthParserTests.txt";

function wfLabeledSectionTransclusionHeading() 
{
  global $wgParser;
  $wgParser->setFunctionHook( 'lsth', 'wfLstIncludeHeading' );
}

function wfLabeledSectionTransclusionHeadingMagic( &$magicWords, $langCode ) {
  // Add the magic words
  $magicWords['lsth'] = array( 0, 'lsth' );
  return true;
}

///section inclusion - include all matching sections
function wfLstIncludeHeading(&$parser, $page='', $sec='', $to='')
{
  global $wgHooks;
  
  $title = Title::newFromText($page);

  if (is_null($title) )
    return '';
  
  $text = wfLst_fetch_($parser,$page);
  
  //if article doesn't exist, return a red link.
  if ($text == false)
    return "[[" . $title->getPrefixedText() . "]]";

  //Generate a regex to match the === classical heading section(s) === we're
  //interested in.
  if ($sec == '') 
    $sec = '^';
  else
    $sec = '==+\s*' . preg_quote($sec, '/') . '\s*==+' ;

  $to = '==+\s*' . preg_quote($to, '/');
  $pat =  "/$sec(.*?)\n$to/s";
  
  preg_match_all( $pat, $text . "\n==", $m);
  
  $text = '';
  foreach ($m[1] as $piece)  {
    $text .= $piece;
  }

  return wfLst_parse_($parser,$title,$text, "#lst:${page}|${sec}");
}

?>