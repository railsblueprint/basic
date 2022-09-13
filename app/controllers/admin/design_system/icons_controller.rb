class Admin::DesignSystem::IconsController < Admin::Controller
  before_action do
    breadcrumb t("admin.nav.design_system.design_system"), ""
    breadcrumb t("admin.nav.design_system.icons"), ""
    breadcrumb t("admin.nav.design_system.#{params[:action]}"), url_for
  end

  # rubocop:disable Metrics/MethodLength
  def remix
    @icons =
      {
        Buildings:          %w[ancient-gate ancient-pavilion bank building building-2 building-3 building-4 community
                               government home home-2 home-3 home-4 home-5 home-6 home-7 home-8 home-gear home-heart
                               home-smile home-smile-2 home-wifi hospital hotel store store-2 store-3],
        Business:           %w[advertisement archive
                               archive-drawer at attachment award bar-chart bar-chart-2 bar-chart-box bar-chart-grouped
                               bar-chart-horizontal bookmark bookmark-2 bookmark-3 briefcase briefcase-2 briefcase-3
                               briefcase-4 briefcase-5 bubble-chart calculator calendar calendar-2 calendar-check
                               calendar-event calendar-todo cloud cloud-off copyleft copyright creative-commons
                               creative-commons-by creative-commons-nc creative-commons-nd creative-commons-sa
                               creative-commons-zero customer-service customer-service-2 donut-chart flag flag-2 global
                               honour inbox inbox-archive inbox-unarchive line-chart links mail mail-add mail-check
                               mail-close mail-download mail-forbid mail-lock mail-open mail-send mail-settings
                               mail-star mail-unread mail-volume medal medal-2 pie-chart pie-chart-2 pie-chart-box
                               printer printer-cloud profile projector projector-2 record-mail registered reply
                               reply-all send-plane send-plane-2 service slideshow slideshow-2 slideshow-3 slideshow-4
                               stack trademark window window-2],
        Communication:      %w[chat-1 chat-2 chat-3 chat-4 chat-check chat-delete chat-download chat-follow-up
                               chat-forward chat-heart chat-history chat-new chat-off chat-poll chat-private chat-quote
                               chat-settings chat-smile chat-smile-2 chat-smile-3 chat-upload chat-voice discuss
                               feedback message message-2 message-3 question-answer questionnaire video-chat],
        Design:             %w[anticlockwise anticlockwise-2 artboard artboard-2 ball-pen blur-off brush
                               brush-2 brush-3 brush-4 clockwise clockwise-2 collage compasses compasses-2 contrast
                               contrast-2 contrast-drop contrast-drop-2 crop crop-2 drag-drop drag-move drag-move-2
                               drop edit edit-2 edit-box edit-circle eraser focus focus-2 focus-3 grid hammer ink-bottle
                               input-method layout layout-2 layout-3 layout-4 layout-5 layout-6 layout-bottom
                               layout-bottom-2 layout-column layout-grid layout-left layout-left-2 layout-masonry
                               layout-right layout-right-2 layout-row layout-top layout-top-2 magic mark-pen markup
                               paint paint-brush palette pantone pen-nib pencil pencil-ruler pencil-ruler-2 quill-pen
                               ruler ruler-2 scissors scissors-2 scissors-cut screenshot screenshot-2 shape shape-2 sip
                               slice t-box table table-alt tools],
        Development:        ["braces", "brackets", "bug", "bug-2", "code", "code-box", "code-s",
                             "code-s-slash", "command", "css3", "cursor", "git-branch", "git-commit", "git-merge",
                             "git-pull-request", "git-repository", "git-repository-commits", "git-repository-private",
                             "html5", "parentheses", "terminal", "terminal-box", "terminal-window"],
        Device:             ["airplay", "barcode", "barcode-box", "base-station", "battery", "battery-2",
                             "battery-2-charge", "battery-charge", "battery-low", "battery-saver", "battery-share",
                             "bluetooth", "bluetooth-connect", "cast", "cellphone", "computer", "cpu", "dashboard-2",
                             "dashboard-3", "database", "database-2", "device", "device-recover", "dual-sim-1",
                             "dual-sim-2", "fingerprint", "fingerprint-2", "gamepad", "gps", "gradienter",
                             "hard-drive", "hard-drive-2", "hotspot", "install", "keyboard", "keyboard-box", "mac",
                             "macbook", "mouse", "phone", "phone-find", "phone-lock", "qr-code", "qr-scan",
                             "qr-scan-2", "radar", "remote-control", "remote-control-2", "restart", "rotate-lock",
                             "router", "rss", "save", "save-2", "save-3", "scan", "scan-2", "sd-card", "sd-card-mini",
                             "sensor", "server", "shut-down", "signal-wifi", "signal-wifi-1", "signal-wifi-2",
                             "signal-wifi-3", "signal-wifi-error", "signal-wifi-off", "sim-card", "sim-card-2",
                             "smartphone", "tablet", "tv", "tv-2", "u-disk", "uninstall", "usb", "wifi", "wifi-off",
                             "wireless-charging"],
        Document:           %w[article bill book book-2 book-3 book-mark book-open book-read booklet
                               clipboard contacts-book contacts-book-2 contacts-book-upload draft file file-2 file-3
                               file-4 file-add file-chart file-chart-2 file-cloud file-code file-copy file-copy-2
                               file-damage file-download file-edit file-excel file-excel-2 file-forbid file-gif
                               file-history file-hwp file-info file-list file-list-2 file-list-3 file-lock file-mark
                               file-music file-paper file-paper-2 file-pdf file-ppt file-ppt-2 file-reduce file-search
                               file-settings file-shield file-shield-2 file-shred file-text file-transfer file-unknow
                               file-upload file-user file-warning file-word file-word-2 file-zip folder folder-2
                               folder-3 folder-4 folder-5 folder-add folder-chart folder-chart-2 folder-download
                               folder-forbid folder-history folder-info folder-keyhole folder-lock folder-music
                               folder-open folder-received folder-reduce folder-settings folder-shared folder-shield
                               folder-shield-2 folder-transfer folder-unknow folder-upload folder-user folder-warning
                               folder-zip folders keynote markdown newspaper numbers pages sticky-note sticky-note-2
                               survey task todo],
        Editor:             %w[a-b align-bottom align-center align-justify align-left align-right align-top
                               align-vertically asterisk attachment-2 bold bring-forward bring-to-front code-view
                               delete-column delete-row double-quotes-l double-quotes-r emphasis emphasis-cn
                               english-input flow-chart font-color font-size font-size-2 format-clear functions h-1
                               h-2 h-3 h-4 h-5 h-6 hashtag heading indent-decrease indent-increase input-cursor-move
                               insert-column-left insert-column-right insert-row-bottom insert-row-top italic
                               line-height link link-m link-unlink link-unlink-m list-check list-check-2 list-ordered
                               list-unordered merge-cells-horizontal merge-cells-vertical mind-map node-tree number-0
                               number-1 number-2 number-3 number-4 number-5 number-6 number-7 number-8 number-9 omega
                               organization-chart page-separator paragraph pinyin-input question-mark rounded-corner
                               send-backward send-to-back separator single-quotes-l single-quotes-r sort-asc sort-desc
                               space split-cells-horizontal split-cells-vertical strikethrough strikethrough-2 subscript
                               subscript-2 superscript superscript-2 table-2 text text-direction-l text-direction-r
                               text-spacing text-wrap translate translate-2 underline wubi-input],
        Finance:            %w[24-hours auction bank-card bank-card-2 bit-coin coin coins copper-coin
                               copper-diamond coupon coupon-2 coupon-3 coupon-4 coupon-5 currency exchange exchange-box
                               exchange-cny exchange-dollar exchange-funds funds funds-box gift gift-2 hand-coin
                               hand-heart increase-decrease money-cny-box money-cny-circle money-dollar-box
                               money-dollar-circle money-euro-box money-euro-circle money-pound-box money-pound-circle
                               percent price-tag price-tag-2 price-tag-3 red-packet refund refund-2 safe safe-2
                               secure-payment shopping-bag shopping-bag-2 shopping-bag-3 shopping-basket
                               shopping-basket-2 shopping-cart shopping-cart-2 stock swap swap-box ticket ticket-2
                               trophy vip vip-crown vip-crown-2 vip-diamond wallet wallet-2 wallet-3 water-flash],
        "Health & Medical": %w[capsule dislike dossier empathize first-aid-kit flask hand-sanitizer
                               health-book heart heart-2 heart-3 heart-add heart-pulse hearts infrared-thermometer
                               lungs medicine-bottle mental-health microscope nurse psychotherapy pulse rest-time
                               stethoscope surgical-mask syringe test-tube thermometer virus zzz],
        Logos:              %w[alipay amazon android angularjs app-store apple baidu behance bilibili centos
                               chrome codepen coreos dingding discord disqus douban dribbble drive dropbox edge evernote
                               facebook facebook-box facebook-circle finder firefox flutter gatsby github gitlab google
                               google-play honor-of-kings ie instagram invision kakao-talk line linkedin linkedin-box
                               mastercard mastodon medium messenger microsoft mini-program netease-cloud-music netflix
                               npmjs open-source opera patreon paypal pinterest pixelfed playstation product-hunt qq
                               reactjs reddit remixicon safari skype slack snapchat soundcloud spectrum spotify
                               stack-overflow stackshare steam switch taobao telegram trello tumblr twitch twitter
                               ubuntu unsplash vimeo visa vuejs wechat wechat-2 wechat-pay weibo whatsapp windows xbox
                               xing youtube zcool zhihu],
        Map:                %w[anchor barricade bike bus bus-2 bus-wifi car car-washing caravan charging-pile
                               charging-pile-2 china-railway compass compass-2 compass-3 compass-4 compass-discover cup
                               direction e-bike e-bike-2 earth flight-land flight-takeoff footprint gas-station globe
                               goblet guide hotel-bed lifebuoy luggage-cart luggage-deposit map map-2 map-pin map-pin-2
                               map-pin-3 map-pin-4 map-pin-5 map-pin-add map-pin-range map-pin-time map-pin-user
                               motorbike navigation oil parking parking-box passport pin-distance plane police-car
                               pushpin pushpin-2 restaurant restaurant-2 riding road-map roadster rocket rocket-2 route
                               run sailboat ship ship-2 signal-tower space-ship steering steering-2 subway subway-wifi
                               suitcase suitcase-2 suitcase-3 takeaway taxi taxi-wifi traffic-light train train-wifi
                               treasure-map truck walk],
        Media:              %w[4k album aspect-ratio broadcast camera camera-2 camera-3 camera-lens camera-off
                               camera-switch clapperboard closed-captioning disc dv dvd eject equalizer film fullscreen
                               fullscreen-exit gallery gallery-upload hd headphone hq image image-2 image-add image-edit
                               landscape live mic mic-2 mic-off movie movie-2 music music-2 mv notification
                               notification-2 notification-3 notification-4 notification-off order-play pause
                               pause-circle pause-mini phone-camera picture-in-picture picture-in-picture-2
                               picture-in-picture-exit play play-circle play-list play-list-2 play-list-add play-mini
                               polaroid polaroid-2 radio radio-2 record-circle repeat repeat-2 repeat-one rewind
                               rewind-mini rhythm shuffle skip-back skip-back-mini skip-forward skip-forward-mini
                               sound-module speaker speaker-2 speaker-3 speed speed-mini stop stop-circle stop-mini
                               surround-sound tape video video-add video-download video-upload vidicon vidicon-2
                               voiceprint volume-down volume-mute volume-off-vibrate volume-up volume-vibrate webcam],
        System:             %w[add add-box add-circle alarm alarm-warning alert apps apps-2 arrow-down
                               arrow-down-circle arrow-down-s arrow-drop-down arrow-drop-left arrow-drop-right
                               arrow-drop-up arrow-go-back arrow-go-forward arrow-left arrow-left-circle arrow-left-down
                               arrow-left-right arrow-left-s arrow-left-up arrow-right arrow-right-circle
                               arrow-right-down arrow-right-s arrow-right-up arrow-up arrow-up-circle arrow-up-down
                               arrow-up-s check check-double checkbox checkbox-blank checkbox-blank-circle
                               checkbox-circle checkbox-indeterminate checkbox-multiple checkbox-multiple-blank close
                               close-circle dashboard delete-back delete-back-2 delete-bin delete-bin-2 delete-bin-3
                               delete-bin-4 delete-bin-5 delete-bin-6 delete-bin-7 divide download download-2
                               download-cloud download-cloud-2 error-warning external-link eye eye-2 eye-close eye-off
                               filter filter-2 filter-3 filter-off find-replace forbid forbid-2 function history
                               indeterminate-circle information list-settings loader loader-2 loader-3 loader-4 l
                               oader-5 lock lock-2 lock-password lock-unlock login-box login-circle logout-box
                               logout-box-r logout-circle logout-circle-r menu menu-2 menu-3 menu-4 menu-5 menu-add
                               menu-fold more more-2 notification-badge question radio-button refresh search search-2
                               search-eye settings settings-2 settings-3 settings-4 settings-5 settings-6 share
                               share-box share-circle share-forward share-forward-2 share-forward-box shield
                               shield-check shield-cross shield-flash shield-keyhole shield-star shield-user side-bar
                               spam spam-2 spam-3 star star-half star-half-s star-s subtract thumb-down thumb-up time
                               timer timer-2 timer-flash toggle upload upload-2 upload-cloud upload-cloud-2 zoom-in
                               zoom-out],
        "User&Faces":       %w[account-box account-circle account-pin-box account-pin-circle admin aliens
                               bear-smile body-scan contacts criminal emotion emotion-2 emotion-happy emotion-laugh
                               emotion-normal emotion-sad emotion-unhappy genderless ghost ghost-2 ghost-smile group
                               group-2 men mickey open-arm parent robot skull skull-2 spy star-smile team travesti
                               user user-2 user-3 user-4 user-5 user-6 user-add user-follow user-heart user-location
                               user-received user-received-2 user-search user-settings user-shared user-shared-2
                               user-smile user-star user-unfollow user-voice women],
        Weather:            %w[blaze celsius cloud-windy cloudy cloudy-2 drizzle earthquake fahrenheit fire
                               flashlight flood foggy hail haze haze-2 heavy-showers meteor mist moon moon-clear
                               moon-cloudy moon-foggy rainbow rainy showers snowy sun sun-cloudy sun-foggy temp-cold
                               temp-hot thunderstorms tornado typhoon windy],
        Others:             %w[basketball bell billiards boxing cactus cake cake-2 cake-3 character-recognition
                               door door-closed door-lock door-lock-box door-open football fridge game handbag key
                               key-2 knife knife-blood leaf lightbulb lightbulb-flash outlet outlet-2 ping-pong plant
                               plug plug-2 recycle reserved scales scales-2 scales-3 seedling shirt sword t-shirt
                               t-shirt-2 t-shirt-air umbrella voice-recognition wheelchair]
      }
  end

  def fontawesome
    # rubocop:disable Metrics/CollectionLiteralLength
    @icons = %w[
      0 1 2 3 4 5 6 7 8 9 a ad add address-book address-card adjust air-freshener align-center align-justify
      align-left align-right allergies ambulance american-sign-language-interpreting anchor
      anchor-circle-check
      anchor-circle-exclamation anchor-circle-xmark anchor-lock angle-double-down angle-double-left
      angle-double-right
      angle-double-up angle-down angle-left angle-right angle-up angles-down angles-left angles-right angles-up
      angry
      ankh apple-alt apple-whole archive archway area-chart arrow-alt-circle-down
      arrow-alt-circle-left
      arrow-alt-circle-right arrow-alt-circle-up arrow-circle-down arrow-circle-left arrow-circle-right arrow-circle-up
      arrow-down arrow-down-1-9 arrow-down-9-1 arrow-down-a-z arrow-down-long arrow-down-short-wide
      arrow-down-up-across-line arrow-down-up-lock arrow-down-wide-short arrow-down-z-a arrow-left arrow-left-long
      arrow-left-rotate arrow-pointer arrow-right arrow-right-arrow-left arrow-right-from-bracket arrow-right-from-file
      arrow-right-long arrow-right-rotate arrow-right-to-bracket arrow-right-to-city arrow-right-to-file
      arrow-rotate-back arrow-rotate-backward arrow-rotate-forward arrow-rotate-left arrow-rotate-right arrow-trend-down
      arrow-trend-up arrow-turn-down arrow-turn-up arrow-up arrow-up-1-9 arrow-up-9-1 arrow-up-a-z arrow-up-from-bracket
      arrow-up-from-ground-water arrow-up-from-water-pump arrow-up-long arrow-up-right-dots arrow-up-right-from-square
      arrow-up-short-wide arrow-up-wide-short arrow-up-z-a arrows arrows-alt arrows-alt-h arrows-alt-v
      arrows-down-to-line arrows-down-to-people arrows-h arrows-left-right arrows-left-right-to-line arrows-rotate
      arrows-spin arrows-split-up-and-left arrows-to-circle arrows-to-dot arrows-to-eye arrows-turn-right
      arrows-turn-to-dots arrows-up-down arrows-up-down-left-right arrows-up-to-line arrows-v asl-interpreting
      assistive-listening-systems asterisk at atlas atom audio-description austral-sign automobile award b baby
      baby-carriage backspace backward backward-fast backward-step bacon bacteria bacterium bag-shopping bahai baht-sign
      balance-scale balance-scale-left balance-scale-right ban ban-smoking band-aid bandage bangladeshi-taka-sign bank
      bar-chart barcode bars bars-progress bars-staggered baseball baseball-ball baseball-bat-ball basket-shopping
      basketball basketball-ball bath bathtub battery battery-0 battery-2 battery-3 battery-4 battery-5 battery-car
      battery-empty battery-full battery-half battery-quarter battery-three-quarters bed bed-pulse beer beer-mug-empty
      bell bell-concierge bell-slash bezier-curve bible bicycle biking binoculars biohazard birthday-cake bitcoin-sign
      blackboard blender blender-phone blind blog bold bolt bolt-lightning bomb bone bong book book-atlas book-bible
      book-bookmark book-dead book-journal-whills book-medical book-open book-open-reader book-quran book-reader
      book-skull book-tanakh bookmark border-all border-none border-style border-top-left bore-hole bottle-droplet
      bottle-water bowl-food bowl-rice bowling-ball box box-archive box-open box-tissue boxes boxes-alt boxes-packing
      boxes-stacked braille brain brazilian-real-sign bread-slice bridge bridge-circle-check bridge-circle-exclamation
      bridge-circle-xmark bridge-lock bridge-water briefcase briefcase-clock briefcase-medical broadcast-tower broom
      broom-ball brush bucket bug bug-slash bugs building building-circle-arrow-right building-circle-check
      building-circle-exclamation building-circle-xmark building-columns building-flag building-lock building-ngo
      building-shield building-un building-user building-wheat bullhorn bullseye burger burn burst bus bus-alt
      bus-simple
      business-time c cab cable-car cake cake-candles calculator calendar calendar-alt calendar-check calendar-day
      calendar-days calendar-minus calendar-plus calendar-times calendar-week calendar-xmark camera camera-alt
      camera-retro camera-rotate campground cancel candy-cane cannabis capsules car car-alt car-battery car-burst
      car-crash car-on car-rear car-side car-tunnel caravan caret-down caret-left caret-right caret-square-down
      caret-square-left caret-square-right caret-square-up caret-up carriage-baby carrot cart-arrow-down cart-flatbed
      cart-flatbed-suitcase cart-plus cart-shopping cash-register cat cedi-sign cent-sign certificate chain chain-broken
      chain-slash chair chalkboard chalkboard-teacher chalkboard-user champagne-glasses charging-station chart-area
      chart-bar chart-column chart-gantt chart-line chart-pie chart-simple check check-circle check-double check-square
      check-to-slot cheese chess chess-bishop chess-board chess-king chess-knight chess-pawn chess-queen chess-rook
      chevron-circle-down chevron-circle-left chevron-circle-right chevron-circle-up chevron-down chevron-left
      chevron-right chevron-up child child-combatant child-dress child-reaching child-rifle children church circle
      circle-arrow-down circle-arrow-left circle-arrow-right circle-arrow-up circle-check circle-chevron-down
      circle-chevron-left circle-chevron-right circle-chevron-up circle-dollar-to-slot circle-dot circle-down
      circle-exclamation circle-h circle-half-stroke circle-info circle-left circle-minus circle-nodes circle-notch
      circle-pause circle-play circle-plus circle-question circle-radiation circle-right circle-stop circle-up
      circle-user circle-xmark city clapperboard clinic-medical clipboard clipboard-check clipboard-list
      clipboard-question clipboard-user clock clock-four clock-rotate-left clone close closed-captioning cloud
      cloud-arrow-down cloud-arrow-up cloud-bolt cloud-download cloud-download-alt cloud-meatball cloud-moon
      cloud-moon-rain cloud-rain cloud-showers-heavy cloud-showers-water cloud-sun cloud-sun-rain cloud-upload
      cloud-upload-alt clover cny cocktail code code-branch code-commit code-compare code-fork code-merge
      code-pull-request coffee cog cogs coins colon-sign columns comment comment-alt comment-dollar comment-dots
      comment-medical comment-slash comment-sms commenting comments comments-dollar compact-disc compass compass-
      drafting
      compress compress-alt compress-arrows-alt computer computer-mouse concierge-bell contact-book contact-card cookie
      cookie-bite copy copyright couch cow credit-card credit-card-alt crop crop-alt crop-simple cross crosshairs crow
      crown crutch cruzeiro-sign cube cubes cubes-stacked cut cutlery d dashboard database deaf deafness dedent
      delete-left democrat desktop desktop-alt dharmachakra diagnoses diagram-next diagram-predecessor diagram-project
      diagram-successor diamond diamond-turn-right dice dice-d20 dice-d6 dice-five dice-four dice-one dice-six
      dice-three
      dice-two digging digital-tachograph directions disease display divide dizzy dna dog dollar dollar-sign dolly
      dolly-box dolly-flatbed donate dong-sign door-closed door-open dot-circle dove down-left-and-up-right-to-center
      down-long download drafting-compass dragon draw-polygon drivers-license droplet droplet-slash drum drum-steelpan
      drumstick-bite dumbbell dumpster dumpster-fire dungeon e ear-deaf ear-listen earth earth-africa earth-america
      earth-americas earth-asia earth-europe earth-oceania edit egg eject elevator ellipsis ellipsis-h ellipsis-v
      ellipsis-vertical envelope envelope-circle-check envelope-open envelope-open-text envelope-square envelopes-bulk
      equals eraser ethernet eur euro euro-sign exchange exchange-alt exclamation exclamation-circle
      exclamation-triangle
      expand expand-alt expand-arrows-alt explosion external-link external-link-alt external-link-square
      external-link-square-alt eye eye-dropper eye-dropper-empty eye-low-vision eye-slash eyedropper f face-angry
      face-dizzy face-flushed face-frown face-frown-open face-grimace face-grin face-grin-beam face-grin-beam-sweat
      face-grin-hearts face-grin-squint face-grin-squint-tears face-grin-stars face-grin-tears face-grin-tongue
      face-grin-tongue-squint face-grin-tongue-wink face-grin-wide face-grin-wink face-kiss face-kiss-beam
      face-kiss-wink-heart face-laugh face-laugh-beam face-laugh-squint face-laugh-wink face-meh face-meh-blank
      face-rolling-eyes face-sad-cry face-sad-tear face-smile face-smile-beam face-smile-wink face-surprise face-tired
      fan fast-backward fast-forward faucet faucet-drip fax feather feather-alt feather-pointed feed female ferry
      fighter-jet file file-alt file-archive file-arrow-down file-arrow-up file-audio file-circle-check
      file-circle-exclamation file-circle-minus file-circle-plus file-circle-question file-circle-xmark file-clipboard
      file-code file-contract file-csv file-download file-edit file-excel file-export file-image file-import
      file-invoice
      file-invoice-dollar file-lines file-medical file-medical-alt file-pdf file-pen file-powerpoint file-prescription
      file-shield file-signature file-text file-upload file-video file-waveform file-word file-zipper fill
      fill-drip film
      filter filter-circle-dollar filter-circle-xmark fingerprint fire fire-alt fire-burner fire-extinguisher
      fire-flame-curved fire-flame-simple first-aid fish fish-fins fist-raised flag flag-checkered flag-usa flask
      flask-vial floppy-disk florin-sign flushed folder folder-blank folder-closed folder-minus folder-open
      folder-plus folder-tree font football football-ball forward forward-fast forward-step franc-sign frog frown
      frown-open funnel-dollar futbol futbol-ball g gamepad gas-pump gauge gauge-high gauge-med gauge-simple
      gauge-simple-high gauge-simple-med gavel gbp gear gears gem genderless ghost gift gifts glass-cheers glass-martini
      glass-martini-alt glass-water glass-water-droplet glass-whiskey glasses globe globe-africa globe-americas
      globe-asia globe-europe globe-oceania golf-ball golf-ball-tee gopuram graduation-cap greater-than
      greater-than-equal grimace grin grin-alt grin-beam grin-beam-sweat grin-hearts grin-squint grin-squint-tears
      grin-stars grin-tears grin-tongue grin-tongue-squint grin-tongue-wink grin-wink grip grip-horizontal grip-lines
      grip-lines-vertical grip-vertical group-arrows-rotate guarani-sign guitar gun h h-square hamburger hammer hamsa
      hand hand-back-fist hand-dots hand-fist hand-holding hand-holding-dollar hand-holding-droplet hand-holding-hand
      hand-holding-heart hand-holding-medical hand-holding-usd hand-holding-water hand-lizard hand-middle-finger
      hand-paper hand-peace hand-point-down hand-point-left hand-point-right hand-point-up hand-pointer hand-rock
      hand-scissors hand-sparkles hand-spock handcuffs hands hands-american-sign-language-interpreting
      hands-asl-interpreting hands-bound hands-bubbles hands-clapping hands-helping hands-holding hands-holding-child
      hands-holding-circle hands-praying hands-wash handshake handshake-alt handshake-alt-slash handshake-angle
      handshake-simple handshake-simple-slash handshake-slash hanukiah hard-drive hard-hat hard-of-hearing hashtag
      hat-cowboy hat-cowboy-side hat-hard hat-wizard haykal hdd head-side-cough head-side-cough-slash head-side-mask
      head-side-virus header heading headphones headphones-alt headphones-simple headset heart heart-broken
      heart-circle-bolt heart-circle-check heart-circle-exclamation heart-circle-minus heart-circle-plus
      heart-circle-xmark heart-crack heart-music-camera-bolt heart-pulse heartbeat helicopter helicopter-symbol
      helmet-safety helmet-un highlighter hiking hill-avalanche hill-rockslide hippo history hockey-puck holly-berry
      home
      home-alt home-lg home-lg-alt home-user horse horse-head hospital hospital-alt hospital-symbol hospital-user
      hospital-wide hot-tub hot-tub-person hotdog hotel hourglass hourglass-1 hourglass-2 hourglass-3 hourglass-empty
      hourglass-end hourglass-half hourglass-start house house-chimney house-chimney-crack house-chimney-medical
      house-chimney-user house-chimney-window house-circle-check house-circle-exclamation house-circle-xmark house-crack
      house-damage house-fire house-flag house-flood-water house-flood-water-circle-arrow-right house-laptop house-lock
      house-medical house-medical-circle-check house-medical-circle-exclamation house-medical-circle-xmark
      house-medical-flag house-signal house-tsunami house-user hryvnia hryvnia-sign hurricane i i-cursor ice-cream
      icicles icons id-badge id-card id-card-alt id-card-clip igloo ils image image-portrait images inbox indent
      indian-rupee indian-rupee-sign industry infinity info info-circle inr institution italic j jar jar-wheat jedi
      jet-fighter jet-fighter-up joint journal-whills jpy jug-detergent k kaaba key keyboard khanda kip-sign kiss
      kiss-beam kiss-wink-heart kit-medical kitchen-set kiwi-bird krw l ladder-water land-mine-on landmark landmark-alt
      landmark-dome landmark-flag language laptop laptop-code laptop-file laptop-house laptop-medical lari-sign laugh
      laugh-beam laugh-squint laugh-wink layer-group leaf left-long left-right legal lemon less-than less-than-equal
      level-down level-down-alt level-up level-up-alt life-ring lightbulb line-chart lines-leaning link link-slash
      lira-sign list list-1-2 list-alt list-check list-dots list-numeric list-ol list-squares list-ul litecoin-sign
      location location-arrow location-crosshairs location-dot location-pin location-pin-lock lock lock-open locust
      long-arrow-alt-down long-arrow-alt-left long-arrow-alt-right long-arrow-alt-up long-arrow-down long-arrow-left
      long-arrow-right long-arrow-up low-vision luggage-cart lungs lungs-virus m magic magic-wand-sparkles magnet
      magnifying-glass magnifying-glass-arrow-right magnifying-glass-chart magnifying-glass-dollar
      magnifying-glass-location magnifying-glass-minus magnifying-glass-plus mail-bulk mail-forward mail-reply
      mail-reply-all male manat-sign map map-location map-location-dot map-marked map-marked-alt map-marker
      map-marker-alt map-pin map-signs marker mars mars-and-venus mars-and-venus-burst mars-double mars-stroke
      mars-stroke-h mars-stroke-right mars-stroke-up mars-stroke-v martini-glass martini-glass-citrus
      martini-glass-empty
      mask mask-face mask-ventilator masks-theater mattress-pillow maximize medal medkit meh meh-blank meh-rolling-eyes
      memory menorah mercury message meteor microchip microphone microphone-alt microphone-alt-slash microphone-lines
      microphone-lines-slash microphone-slash microscope mill-sign minimize minus minus-circle minus-square mitten
      mobile
      mobile-alt mobile-android mobile-android-alt mobile-button mobile-phone mobile-retro mobile-screen
      mobile-screen-button money-bill money-bill-1 money-bill-1-wave money-bill-alt money-bill-transfer
      money-bill-trend-up money-bill-wave money-bill-wave-alt money-bill-wheat money-bills money-check money-check-alt
      money-check-dollar monument moon mortar-board mortar-pestle mosque mosquito mosquito-net motorcycle mound mountain
      mountain-city mountain-sun mouse mouse-pointer mug-hot mug-saucer multiply museum music n naira-sign navicon
      network-wired neuter newspaper not-equal notdef note-sticky notes-medical o object-group object-ungroup oil-can
      oil-well om otter outdent p pager paint-brush paint-roller paintbrush palette pallet panorama paper-plane
      paperclip
      parachute-box paragraph parking passport pastafarianism paste pause pause-circle paw peace pen pen-alt pen-clip
      pen-fancy pen-nib pen-ruler pen-square pen-to-square pencil pencil-alt pencil-ruler pencil-square people-arrows
      people-arrows-left-right people-carry people-carry-box people-group people-line people-pulling people-robbery
      people-roof pepper-hot percent percentage person person-arrow-down-to-line person-arrow-up-from-line person-biking
      person-booth person-breastfeeding person-burst person-cane person-chalkboard person-circle-check
      person-circle-exclamation person-circle-minus person-circle-plus person-circle-question person-circle-xmark
      person-digging person-dots-from-line person-dress person-dress-burst person-drowning person-falling
      person-falling-burst person-half-dress person-harassing person-hiking person-military-pointing
      person-military-rifle person-military-to-person person-praying person-pregnant person-rays person-rifle
      person-running person-shelter person-skating person-skiing person-skiing-nordic person-snowboarding
      person-swimming
      person-through-window person-walking person-walking-arrow-loop-left person-walking-arrow-right
      person-walking-dashed-line-arrow-right person-walking-luggage person-walking-with-cane peseta-sign peso-sign phone
      phone-alt phone-flip phone-slash phone-square phone-square-alt phone-volume photo-film photo-video pie-chart
      piggy-bank pills ping-pong-paddle-ball pizza-slice place-of-worship plane plane-arrival plane-circle-check
      plane-circle-exclamation plane-circle-xmark plane-departure plane-lock plane-slash plane-up plant-wilt plate-wheat
      play play-circle plug plug-circle-bolt plug-circle-check plug-circle-exclamation plug-circle-minus
      plug-circle-plus
      plug-circle-xmark plus plus-circle plus-minus plus-square podcast poll poll-h poo poo-bolt poo-storm poop portrait
      pound-sign power-off pray praying-hands prescription prescription-bottle prescription-bottle-alt
      prescription-bottle-medical print procedures project-diagram pump-medical pump-soap puzzle-piece q qrcode
      question question-circle quidditch quidditch-broom-ball quote-left quote-left-alt quote-right quote-right-alt
      quran
      r radiation radiation-alt radio rainbow random ranking-star receipt record-vinyl rectangle-ad rectangle-list
      rectangle-times rectangle-xmark recycle redo redo-alt refresh registered remove remove-format reorder
      repeat reply reply-all republican restroom retweet ribbon right-from-bracket right-left right-long
      right-to-bracket
      ring rmb road road-barrier road-bridge road-circle-check road-circle-exclamation road-circle-xmark road-lock
      road-spikes robot rocket rod-asclepius rod-snake rotate rotate-back rotate-backward rotate-forward rotate-left
      rotate-right rouble route rss rss-square rub ruble ruble-sign rug ruler ruler-combined ruler-horizontal
      ruler-vertical running rupee rupee-sign rupiah-sign s sack-dollar sack-xmark sad-cry sad-tear sailboat satellite
      satellite-dish save scale-balanced scale-unbalanced scale-unbalanced-flip school school-circle-check
      school-circle-exclamation school-circle-xmark school-flag school-lock scissors screwdriver screwdriver-wrench
      scroll scroll-torah sd-card search search-dollar search-location search-minus search-plus section seedling server
      shapes share share-alt share-alt-square share-from-square share-nodes share-square sheet-plastic shekel
      shekel-sign sheqel sheqel-sign shield shield-alt shield-blank shield-cat shield-dog shield-halved shield-heart
      shield-virus ship shipping-fast shirt shoe-prints shop shop-lock shop-slash shopping-bag shopping-basket
      shopping-cart shower shrimp shuffle shuttle-space shuttle-van sign sign-hanging sign-in sign-in-alt sign-language
      sign-out sign-out-alt signal signal-5 signal-perfect signature signing signs-post sim-card sink sitemap skating
      skiing skiing-nordic skull skull-crossbones slash sleigh sliders sliders-h smile smile-beam smile-wink smog
      smoking
      smoking-ban sms snowboarding snowflake snowman snowplow soap soccer-ball socks solar-panel sort
      sort-alpha-asc sort-alpha-desc sort-alpha-down sort-alpha-down-alt sort-alpha-up sort-alpha-up-alt sort-amount-asc
      sort-amount-desc sort-amount-down sort-amount-down-alt sort-amount-up sort-amount-up-alt sort-asc sort-desc
      sort-down sort-numeric-asc sort-numeric-desc sort-numeric-down sort-numeric-down-alt sort-numeric-up
      sort-numeric-up-alt sort-up spa space-shuttle spaghetti-monster-flying spell-check spider spinner splotch spoon
      spray-can spray-can-sparkles sprout square square-arrow-up-right square-caret-down square-caret-left
      square-caret-right square-caret-up square-check square-envelope square-full square-h square-minus square-nfi
      square-parking square-pen square-person-confined square-phone square-phone-flip square-plus square-poll-horizontal
      square-poll-vertical square-root-alt square-root-variable square-rss square-share-nodes square-up-right
      square-virus square-xmark sr-only-focusable staff-aesculapius staff-snake stairs stamp stapler star
      star-and-crescent star-half star-half-alt star-half-stroke star-of-david star-of-life step-backward step-forward
      sterling-sign stethoscope sticky-note stop stop-circle stopwatch stopwatch-20 store store-alt store-alt-slash
      store-slash stream street-view strikethrough stroopwafel subscript subtract subway suitcase suitcase-medical
      suitcase-rolling sun sun-plant-wilt superscript surprise swatchbook swimmer swimming-pool synagogue sync sync-alt
      syringe t t-shirt table table-cells table-cells-large table-columns table-list table-tennis
      table-tennis-paddle-ball tablet tablet-alt tablet-android tablet-button tablet-screen-button tablets
      tachograph-digital tachometer tachometer-alt tachometer-alt-average tachometer-alt-fast tachometer-average
      tachometer-fast tag tags tanakh tape tarp tarp-droplet tasks tasks-alt taxi teeth teeth-open teletype television
      temperature-0 temperature-1 temperature-2 temperature-3 temperature-4 temperature-arrow-down temperature-arrow-up
      temperature-down temperature-empty temperature-full temperature-half temperature-high temperature-low
      temperature-quarter temperature-three-quarters temperature-up tenge tenge-sign tent tent-arrow-down-to-line
      tent-arrow-left-right tent-arrow-turn-left tent-arrows-down tents terminal text-height text-slash text-width th
      th-large th-list theater-masks thermometer thermometer-0 thermometer-1 thermometer-2 thermometer-3 thermometer-4
      thermometer-empty thermometer-full thermometer-half thermometer-quarter thermometer-three-quarters thumb-tack
      thumbs-down thumbs-up thumbtack thunderstorm ticket ticket-alt ticket-simple timeline times times-circle
      times-rectangle times-square tint tint-slash tired toggle-off toggle-on toilet toilet-paper toilet-paper-slash
      toilet-portable toilets-portable toolbox tools tooth torah torii-gate tornado tower-broadcast tower-cell
      tower-observation tractor trademark traffic-light trailer train train-subway train-tram tram transgender
      transgender-alt trash trash-alt trash-arrow-up trash-can trash-can-arrow-up trash-restore trash-restore-alt tree
      tree-city triangle-circle-square triangle-exclamation trophy trowel trowel-bricks truck truck-arrow-right
      truck-droplet truck-fast truck-field truck-field-un truck-front truck-loading truck-medical truck-monster
      truck-moving truck-pickup truck-plane truck-ramp-box try tshirt tty turkish-lira turkish-lira-sign turn-down
      turn-up tv tv-alt u umbrella umbrella-beach underline undo undo-alt universal-access university unlink unlock
      unlock-alt unlock-keyhole unsorted up-down up-down-left-right up-long up-right-and-down-left-from-center
      up-right-from-square upload usd user user-alt user-alt-slash user-astronaut user-check user-circle user-clock
      user-cog user-doctor user-edit user-friends user-gear user-graduate user-group user-injured user-large
      user-large-slash user-lock user-md user-minus user-ninja user-nurse user-pen user-plus user-secret user-shield
      user-slash user-tag user-tie user-times user-xmark users users-between-lines users-cog users-gear users-line
      users-rays users-rectangle users-slash users-viewfinder utensil-spoon utensils v van-shuttle vault vcard
      vector-square venus venus-double venus-mars vest vest-patches vial vial-circle-check vial-virus vials video
      video-camera video-slash vihara virus virus-covid virus-covid-slash virus-slash viruses voicemail volcano
      volleyball volleyball-ball volume-control-phone volume-down volume-high volume-low volume-mute volume-off
      volume-times volume-up volume-xmark vote-yea vr-cardboard w walkie-talkie walking wallet wand-magic
      wand-magic-sparkles wand-sparkles warehouse warning water water-ladder wave-square weight weight-hanging
      weight-scale wheat-alt wheat-awn wheat-awn-circle-exclamation wheelchair wheelchair-alt wheelchair-move
      whiskey-glass wifi wifi-3 wifi-strong wind window-close window-maximize window-minimize window-restore wine-bottle
      wine-glass wine-glass-alt wine-glass-empty won won-sign worm wrench x x-ray xmark xmark-circle xmark-square
      xmarks-lines y yen yen-sign yin-yang z zap
    ]
    @brands = %w[
      42-group 500px accessible-icon accusoft adn adversal affiliatetheme airbnb algolia alipay amazon
      amazon-pay amilia android angellist angrycreative angular app-store app-store-ios apper apple apple-pay
      artstation asymmetrik atlassian audible autoprefixer avianex aviato aws bandcamp battle-net behance
      behance-square bilibili bimobject bitbucket bitcoin bity black-tie blackberry blogger blogger-b bluetooth
      bluetooth-b bootstrap bots brave brave-reverse btc buffer buromobelexperte buy-n-large buysellads
      canadian-maple-leaf cc-amazon-pay cc-amex cc-apple-pay cc-diners-club cc-discover cc-jcb cc-mastercard
      cc-paypal cc-stripe cc-visa centercode centos chrome chromecast cloudflare cloudscale cloudsmith cloudversify
      cmplid codepen codiepie confluence connectdevelop contao cotton-bureau cpanel creative-commons
      creative-commons-by creative-commons-nc creative-commons-nc-eu creative-commons-nc-jp creative-commons-nd
      creative-commons-pd creative-commons-pd-alt creative-commons-remix creative-commons-sa
      creative-commons-sampling creative-commons-sampling-plus creative-commons-share creative-commons-zero
      critical-role css3 css3-alt cuttlefish d-and-d d-and-d-beyond dailymotion dashcube debian deezer delicious
      deploydog deskpro dev deviantart dhl diaspora digg digital-ocean discord discourse dochub docker draft2digital
      dribbble dribbble-square dropbox drupal dyalog earlybirds ebay edge edge-legacy elementor ello ember empire
      envira erlang ethereum etsy evernote expeditedssl facebook facebook-f facebook-messenger facebook-square
      fantasy-flight-games fedex fedora figma firefox firefox-browser first-order first-order-alt firstdraft flickr
      flipboard fly font-awesome font-awesome-alt font-awesome-flag font-awesome-logo-full fonticons fonticons-fi
      fort-awesome fort-awesome-alt forumbee foursquare free-code-camp freebsd fulcrum galactic-republic
      galactic-senate get-pocket gg gg-circle git git-alt git-square github github-alt github-square gitkraken
      gitlab gitlab-square gitter glide glide-g gofore golang goodreads goodreads-g google google-drive google-pay
      google-play google-plus google-plus-g google-plus-square google-scholar google-wallet gratipay grav gripfire
      grunt guilded gulp hacker-news hacker-news-square hackerrank hashnode hips hire-a-helper hive hooli hornbill
      hotjar houzz html5 hubspot ideal imdb innosoft instagram instagram-square instalod intercom internet-explorer
      invision ioxhost itch-io itunes itunes-note java jedi-order jenkins jira joget joomla js js-square jsfiddle
      kaggle keybase keycdn kickstarter kickstarter-k korvue laravel lastfm lastfm-square leanpub less letterboxd
      line linkedin linkedin-in linode linux lyft magento mailchimp mandalorian markdown mastodon maxcdn mdb medapps
      medium medium-m medrt meetup megaport mendeley meta microblog microsoft mintbit mix mixcloud mixer mizuni modx
      monero napster neos nfc-directional nfc-symbol nimblr node node-js npm ns8 nutritionix octopus-deploy
      odnoklassniki odnoklassniki-square odysee old-republic opencart openid opensuse opera optin-monster orcid osi
      padlet page4 pagelines palfed patreon paypal perbyte periscope phabricator phoenix-framework phoenix-squadron
      php pied-piper pied-piper-alt pied-piper-hat pied-piper-pp pied-piper-square pinterest pinterest-p
      pinterest-square pix pixiv playstation product-hunt pushed python qq quinscape quora r-project raspberry-pi
      ravelry react reacteurope readme rebel red-river reddit reddit-alien reddit-square redhat rendact renren
      replyd researchgate resolving rev rocketchat rockrms rust safari salesforce sass schlix screenpal scribd
      searchengin sellcast sellsy servicestack shirtsinbulk shoelace shopify shopware signal-messenger simplybuilt
      sistrix sith sitrox sketch skyatlas skype slack slack-hash slideshare snapchat snapchat-ghost snapchat-square
      soundcloud sourcetree space-awesome speakap speaker-deck spotify square-behance square-dribbble
      square-facebook square-font-awesome square-font-awesome-stroke square-git square-github square-gitlab
      square-google-plus square-hacker-news square-instagram square-js square-lastfm square-letterboxd
      square-odnoklassniki square-pied-piper square-pinterest square-reddit square-snapchat square-steam
      square-threads square-tumblr square-twitter square-viadeo square-vimeo square-whatsapp square-x-twitter
      square-xing square-youtube squarespace stack-exchange stack-overflow stackpath staylinked steam steam-square
      steam-symbol sticker-mule strava stripe stripe-s stubber studiovinari stumbleupon stumbleupon-circle
      superpowers supple suse swift symfony teamspeak telegram telegram-plane tencent-weibo the-red-yeti themeco
      themeisle think-peaks threads tiktok trade-federation trello tumblr tumblr-square twitch twitter
      twitter-square typo3 uber ubuntu uikit umbraco uncharted uniregistry unity unsplash untappd ups upwork usb
      usps ussunnah vaadin viacoin viadeo viadeo-square viber vimeo vimeo-square vimeo-v vine vk vnv vuejs
      watchman-monitoring waze webflow weebly weibo weixin whatsapp whatsapp-square whmcs wikipedia-w windows
      wirsindhandwerk wix wizards-of-the-coast wodu wolf-pack-battalion wordpress wordpress-simple wpbeginner
      wpexplorer wpforms wpressr wsh x-twitter xbox xing xing-square y-combinator yahoo yammer yandex
      yandex-international yarn yelp yoast youtube youtube-square
      zhihu
    ]
    # rubocop:enable Metrics/CollectionLiteralLength
  end

  # rubocop:enable Metrics/MethodLength
end
