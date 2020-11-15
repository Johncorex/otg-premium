<?php
header('Content-Type: application/json');

if(!defined('INITIALIZED'))
	exit;

# error function
function sendError($msg){
	$ret = [];
	$ret["errorCode"] = 3;
	$ret["errorMessage"] = $msg;
	die(json_encode($ret));
}
# event schedule function
function parseEvent($table1, $date, $table2, $bool){
if ($table1) {
	if ($date) {
		if ($table2) {
			$date = $table1->getAttribute('startdate');
			return date_create("{$date}")->format('U');
		} else {
			$date = $table1->getAttribute('enddate');
			return date_create("{$date}")->format('U');
		}
	} else {
		foreach($table1 as $attr) {
			if ($attr) {
				if ($bool) {
					if (intval($attr->getAttribute($table2)) > 0) {
						return true;
					}
						return false;
				}
				return $attr->getAttribute($table2);
			}
		}
	}
}
	return;
}

$request = file_get_contents('php://input');
$result = json_decode($request);
$action = isset($result->type) ? $result->type : '';

switch ($action) {
	case 'cacheinfo':
		$playersonline = $SQL->query("select count(*) from `players_online`")->fetchAll();
		die(json_encode([
			'playersonline' => (intval($playersonline[0][0])),
			'twitchstreams' => 0,
			'twitchviewer' => 0,
			'gamingyoutubestreams' => 0,
			'gamingyoutubeviewer' => 0
		]));
	break;
	case 'eventschedule':
	$eventlist = array();
	$lastupdatetimestamp = time();
	$file_path = Website::getWebsiteConfig()->getValue('serverPath') . 'data/XML/events.xml';
	if (!Website::fileExists($file_path)) {
		die(json_encode([]));
		break;
	}
	$xml = new DOMDocument;
	$xml->load($file_path);
	$tableevent = $xml->getElementsByTagName('event');
	foreach ($tableevent as $event) {
		if ($event) {
		$tmplist = array();
		$tmplist['colorlight'] = parseEvent($event->getElementsByTagName('colors'), false, 'colorlight', false);
		$tmplist['colordark'] = parseEvent($event->getElementsByTagName('colors'), false, 'colordark', false);
		$tmplist['description'] = parseEvent($event->getElementsByTagName('description'), false, 'description', false);
		$tmplist['displaypriority'] = (intval(parseEvent($event->getElementsByTagName('details'), false, 'displaypriority', false)));
		$tmplist['enddate'] = (intval(parseEvent($event, true, false, false)));
		$tmplist['isseasonal'] = parseEvent($event->getElementsByTagName('details'), false, 'isseasonal', true);
		$tmplist['name'] = $event->getAttribute('name');
		$tmplist['startdate'] = (intval(parseEvent($event, true, true, false)));
		$tmplist['specialevent'] = (intval(parseEvent($event->getElementsByTagName('details'), false, 'specialevent', false)));
		$eventlist[] = $tmplist;
		}
	}
	die(json_encode(compact('eventlist', 'lastupdatetimestamp')));
	break;
	case 'boostedcreature':
		$boostDB = $SQL->query("select * from " . $SQL->tableName('boosted_creature'))->fetchAll();
		foreach ($boostDB as $Tableboost) {
		die(json_encode([
			'boostedcreature' => true,
			'raceid' => intval($Tableboost['raceid'])
		]));
		}
	break;
	case 'login':
	
		$port = Website::getServerConfig()->getValue('gameProtocolPort');
	
		// default world info
		$world = [
			'id' => 0,
			'name' => Website::getServerConfig()->getValue('serverName'),
			'externaladdress' => Website::getServerConfig()->getValue('ip'),
			'externalport' => $port,
			'externaladdressprotected' => Website::getServerConfig()->getValue('ip'),
			'externalportprotected' => $port,
			'externaladdressunprotected' => Website::getServerConfig()->getValue('ip'),
			'externalportunprotected' => $port,
			'previewstate' => 0,
			'location' => 'BRA', // BRA, EUR, USA
			'anticheatprotection' => false,
			'pvptype' => array_search(Website::getServerConfig()->getValue('worldType'), ['pvp', 'no-pvp', 'pvp-enforced']),
			'istournamentworld' => false,
			'restrictedstore' => false,
			'currenttournamentphase' => 2
		];
		$characters = [];
		$account = null;
		
		// common columns
		$columns = 'name, level, sex, vocation, looktype, lookhead, lookbody, looklegs, lookfeet, lookaddons, deleted, lastlogin';
		
		$account = new Account();
		$account->loadByEmail($result->email);
		$current_password = Website::encryptPassword($result->password);
		if (!$account->isLoaded() || !$account->isValidPassword($result->password)) {
			sendError('Email or password is not correct.');
		}
		$players = $SQL->query("select {$columns} from players where account_id = " . $account->getId() . " order by name asc")->fetchAll();
		foreach ($players as $player) {
			$characters[] = create_char($player);
		}

		$save = false;
		$timeNow = time();
		$query = $SQL->query("select `premdays`, `lastday` from `accounts` where `id` = " . $account->getId());
			if($query->rowCount() > 0) {
				$query = $query->fetch();
				$premDays = (int)$query['premdays'];
				$lastDay = (int)$query['lastday'];
				$lastLogin = $lastDay;
			}
			else {
				sendError("Error while fetching your account data. Please contact admin.");
		}
		if($premDays != 0 && $premDays != PHP_INT_MAX ) {
			if($lastDay == 0) {
				$lastDay = $timeNow;
				$save = true;
			} else {
				$days = (int)(($timeNow - $lastDay) / 86400);
				if($days > 0) {
					if($days >= $premDays) {
						$premDays = 0;
						$lastDay = 0;
					} else {
						$premDays -= $days;
						$reminder = (int)(($timeNow - $lastDay) % 86400);
						$lastDay = $timeNow - reminder;
					}

					$save = true;
				}
			}
		} else if ($lastDay != 0) {
			$lastDay = 0;
			$save = true;
		}
		if($save) {
			$SQL->query("update `accounts` set `premdays` = " . $premDays . ", `lastday` = " . $lastDay . " where `id` = " . $account->getId());
		}
		$premiumAccount = $premDays > 0;
		$timePremium = time() + ($premDays * 86400);

		$worlds = [$world];
		$playdata = compact('worlds', 'characters');
		$session = [
			'sessionkey' => "$result->email\n$result->password",
			'lastlogintime' => (!$account) ? 0 : $account->getLastLogin(),
			'ispremium' => (!$account) ? true : $account->isPremium(),
			'premiumuntil' => (!$account) ? 0 : (time() + ($account->getPremDays() * 86400)),
			'status' => 'active', // active, frozen or suspended
			'returnernotification' => false,
			'showrewardnews' => true,
			'isreturner' => true,
			'fpstracking' => false,
			'optiontracking' => false,
			'tournamentticketpurchasestate' => 0,
			'emailcoderequest' => false
		];
		die(json_encode(compact('session', 'playdata')));
	break;
	
	default:
		sendError("Unrecognized event {$action}.");
	break;
}
function create_char($player) {
	return [
		'worldid' => 0,
		'name' => $player['name'],
		'ismale' => intval($player['sex']) === 1,
		'tutorial' => false, //intval($player['lastlogin']) === 0,
		'level' => intval($player['level']),
		'vocation' => Website::getVocationName($player['vocation']),
		'outfitid' => intval($player['looktype']),
		'headcolor' => intval($player['lookhead']),
		'torsocolor' => intval($player['lookbody']),
		'legscolor' => intval($player['looklegs']),
		'detailcolor' => intval($player['lookfeet']),
		'addonsflags' => intval($player['lookaddons']),
		'ishidden' => intval($player['deletion']) === 1,
		'istournamentparticipant' => false,
		'remainingdailytournamentplaytime' => 0
	];
}
