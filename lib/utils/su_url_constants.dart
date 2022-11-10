const String accountSubDir = '/4/open/account';
const String homeSubDir = '/4/open/home';
const String deviceListSubDir = '/4/open/device-list';
const String reloadSubDir = '/4/reload';
const String openThirdPartyAppRootSubDir = '/4/open/app/';
const String openHttpsLinks = '/4/open/app/https';

const List<String> functionalSubDirs = <String>[
  accountSubDir,
  homeSubDir,
  deviceListSubDir,
  reloadSubDir,
  openThirdPartyAppRootSubDir
];

const String alexaIdentifier = 'app://alexa';
const String spotifyIdentifier = 'app://spotify';
const String deezerIdentifier = 'app://deezer';
const String tuneinIdentifier = 'app://tunein';
const String youtubemusicIdentifier = 'app://youtubemusic';
const String pandoraIdentifier = 'app://pandora';

const String amazonMusicUrlIdentifier = 'https://amazon';
const String amazonMusicUrl = 'https://amazon.com/us/code';

const String spotifyUrlIndentifier = 'spotify';
const String spotifyUrl = 'https://www.spotify.com/connect';

const String pandoraUrlIdentifier = 'pandora';
const String pandoraUrl = 'https://www.pandora.com/streamunlimited?activation_code=';

const String tidalUrlIndentifier = 'tidal';
const String tidalUrl = 'https://link.tidal.com';

const String alexaUrlIos = 'alexa://';
const String alexaUrlAndroid = 'com.amazon.dee.app';
const String alexaAppStore = 'https://apps.apple.com/de/app/amazon-alexa/id944011620';
const String alexaGooglePlay = 'https://play.google.com/store/apps/details?id=com.amazon.dee.app';

const Map<String, String> alexaAppLinkList = <String, String>{
  'appIos': alexaUrlIos,
  'appAndroid': alexaUrlAndroid,
  'appStore': alexaAppStore,
  'googlePlay': alexaGooglePlay
};

const String spotifyUrlIos = 'spotify://';
const String spotifyUrlAndroid = 'com.spotify.music';
const String spotifyAppStore = 'https://apps.apple.com/de/app/spotify-musik-und-playlists/id324684580';
const String spotifyGooglePlay = 'https://play.google.com/store/apps/details?id=com.spotify.music&hl=de_AT&gl=US';

const Map<String, String> spotifyAppLinkList = <String, String>{
  'appIos': spotifyUrlIos,
  'appAndroid': spotifyUrlAndroid,
  'appStore': spotifyAppStore,
  'googlePlay': spotifyGooglePlay
};

const String deezerUrlIos = 'deezer://';
const String deezerUrlAndroid = 'deezer.android.app';
const String deezerAppStore = 'https://apps.apple.com/de/app/deezer-musik-h%C3%B6rb%C3%BCcher/id292738169';
const String deezerGooglePlay = 'https://play.google.com/store/apps/details?id=deezer.android.app&hl=de_AT&gl=US';

const Map<String, String> deezerAppLinkList = <String, String>{
  'appIos': deezerUrlIos,
  'appAndroid': deezerUrlAndroid,
  'appStore': deezerAppStore,
  'googlePlay': deezerGooglePlay
};

const String tuneinUrlIos = 'tunein://';
const String tuneinUrlAndroid = 'tunein.player';
const String tuneinAppStore = 'https://apps.apple.com/at/app/tunein-radio/id418987775';
const String tuneinGooglePlay = 'https://play.google.com/store/apps/details?id=tunein.player&hl=de_AT&gl=US';

const Map<String, String> tuneinAppLinkList = <String, String>{
  'appIos': tuneinUrlIos,
  'appAndroid': tuneinUrlAndroid,
  'appStore': tuneinAppStore,
  'googlePlay': tuneinGooglePlay
};

const String youtubemusicUrlIos = 'youtubemusic://';
const String youtubemusicUrlAndroid = 'com.google.android.apps.youtube.music';
const String youtubemusicAppStore = 'https://apps.apple.com/at/app/youtube-music/id1017492454';
const String youtubemusicGooglePlay = 'https://play.google.com/store/apps/details?id=com.google.android.apps.youtube.music&hl=de_AT&gl=US';

const Map<String, String> youtubemusicAppLinkList = <String, String>{
  'appIos': youtubemusicUrlIos,
  'appAndroid': youtubemusicUrlAndroid,
  'appStore': youtubemusicAppStore,
  'googlePlay': youtubemusicGooglePlay
};

const String pandoraUrlIos = 'pandora://';
const String pandoraUrlAndroid = 'com.pandora.android';
const String pandoraAppStore = 'https://apps.apple.com/us/app/pandora-music-podcasts/id284035177';
const String pandoraGooglePlay = 'https://play.google.com/store/apps/details?id=com.pandora.android&hl=de_AT&gl=US';

const Map<String, String> pandoraAppLinkList = <String, String>{
  'appIos': pandoraUrlIos,
  'appAndroid': pandoraUrlAndroid,
  'appStore': pandoraAppStore,
  'googlePlay': pandoraGooglePlay
};
