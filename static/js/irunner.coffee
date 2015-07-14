irunner.config ($sceDelegateProvider)->
  $sceDelegateProvider.resourceUrlWhitelist([
    "self"
    "https://byrb.s3.amazonaws.com/static/**"
  ])
  
window.irunnerController = ($scope, $location) ->
  $scope.hoveredInjuries = [] 
  $scope.injuries = window.injuries
  $scope.selectedInjury = null
  $scope.showThumb = true
  $scope.videoClass = ''
  $scope.fadeClass = ''
  $scope.helpClass = ''
  $scope.help = {available: false}
  $scope.injuryNumbers = true
  $scope.clickedAnywhere = false;
  $scope.instructions = window.instructions.text
  $scope.disclaimer = false
  $scope.mini_disclaimer = window.mini_disclaimer.text
  $scope.full_disclaimer = window.full_disclaimer.text
  $scope.mobile_alert = window.mobile_alert.text
  
  video = document.getElementById("figureVideo")
  video.play()
  
  $scope.playVideo = ->
    video = document.getElementById("figureVideo")
    video.play()
    
  $scope.pauseVideo = ->
    video = document.getElementById("figureVideo")
    video.pause()
    
  $scope.pauseAudio = ->
    audio = document.getElementById("ambient")
    audio.pause()
    
  $scope.playAudio = ->
    audio = document.getElementById("ambient")
    audio.play()
  
  $scope.changeSelection = (injury) ->
    $scope.selectedInjury = injury
    $scope.helpClass = "done"
    $scope.clickedAnywhere = true
    setTimeout () ->
      jQuery(".injury-info a").attr("target", "_blank")
    , 100
    
  pivot = ($scope.injuries.length + 1) / 2 
  $scope.injuriesOne = $scope.injuries.slice(0, pivot)
  $scope.injuriesTwo = $scope.injuries.slice(pivot, $scope.injuries.length)

  $scope.videoClicked = () ->
    $scope.help.available = true
    $scope.hoveredInjuries = []
    $scope.injuryNumbers = true
    $scope.selectedInjury = null
    $scope.clickedAnywhere = true
    
  $scope.openDisclaimer = () ->
    $scope.disclaimer = true
    $scope.pauseVideo()
    $scope.pauseAudio()
    
  $scope.closeDisclaimer = () ->
    $scope.disclaimer = false
    $scope.playVideo()
    $scope.playAudio()
    
  fadeVideo = () ->
    video = document.getElementById("figureVideo")
    if video.currentTime > 0.3
      window.clearInterval($scope.playInterval)
      $scope.videoClass = "done"
      $scope.fadeClass = "done"
#      document.getElementById("voiceover").play()
      document.getElementById("ambient").play()
      $scope.$apply()
    
  $scope.playInterval = window.setInterval(fadeVideo, 10)

timeToDegree = (time) ->
  radians = time * 0.62831853071 % (Math.PI * 2.0)
  radians / 0.0174532925

frameToDegree = (frame) ->
  timeToDegree(frame / 5.0)
  
lerp = (a, b, percent) ->
  a + percent * ( b - a )

getFrame = (coords, degree) ->
  for frame_no in [0..50]
    original_degree = frameToDegree(frame_no)
    next_original_degree = frameToDegree(frame_no + 1);
    if original_degree <= degree < next_original_degree
      early_frame = coords[frame_no]
      late_frame_no = if frame_no + 1 < 50 then frame_no + 1 else 0
      late_frame = coords[late_frame_no]
      percent = (degree - original_degree) / (next_original_degree - original_degree)
      x = lerp(early_frame.x or 0, late_frame.x or 0, percent)
      x /= 1280
      y = lerp(early_frame.y or 0, late_frame.y or 0, percent)
      y = (720 - y) / 720

      return {x: x, y: y}

addOpacity = (frames, startAngle, endAngle, degree) ->
  opacity = 0
  fadeSpeed = 10.0
  if startAngle == 0 and endAngle >= 352.5
    opacity = 1.0
  else if startAngle <= degree < startAngle + fadeSpeed
    opacity = lerp(0.0, 1.0, (degree - startAngle) / fadeSpeed)
  else if endAngle - fadeSpeed < degree <= endAngle
    opacity = lerp(0.0, 1.0, (degree - endAngle) / -fadeSpeed)
  else if startAngle > endAngle
    if startAngle < degree or degree < endAngle
      opacity = 1.0
  else if startAngle <= degree <= endAngle
    opacity = 1.0
  frames[degree].opacity = opacity

irunner.directive "irHighlight", ($window)->
  return {
    template: '<img src="{{highlight.image}}" ng-style="css" width="{{ imageWidth }}" height="{{ imageHeight }}">'
    restrict: 'E'
    scope: {
      highlight: "=highlight"
    }
    controller: ($scope, $interval) ->
      $scope.css = {
        position: "fixed"
        top: -900
        left: 0
      }
      
      $scope.initializeWindowSize = ->
        videoRatio = 16.0 / 9.0
        screenRatio = $window.innerWidth / $window.innerHeight 
        if screenRatio > videoRatio
          $scope.videoWidth = $window.innerHeight * videoRatio
          $scope.left = ($window.innerWidth - $scope.videoWidth) / 2.0
        else
          $scope.videoWidth = $window.innerWidth
          $scope.left = 0
        
        $scope.imageWidth = ($scope.videoWidth * $scope.highlight.width) / 1280.0
        $scope.css.width = $scope.imageWidth + "px"
        $scope.imageHeight = ($scope.videoWidth * $scope.highlight.height) / 1280.0
        $scope.css.height = $scope.imageHeight + "px"
      
      $scope.setupFrames = () ->
        $scope.frames = (getFrame($scope.highlight.coordinates, degree) for degree in [0..359])
        addOpacity($scope.frames, $scope.highlight.start,  $scope.highlight.end, degree) for degree in [0..359]
      
      $scope.newPos = () ->
        currentTime = document.getElementById("figureVideo").currentTime
        degree = timeToDegree(currentTime)
        last_degree = Math.floor(degree)
        next_degree = Math.ceil(degree) % 360
        percent = degree - last_degree
  
        x = lerp($scope.frames[last_degree].x, $scope.frames[next_degree].x, percent)
        y = lerp($scope.frames[last_degree].y, $scope.frames[next_degree].y, percent)
  
        $scope.css.opacity = $scope.frames[last_degree].opacity
  
        x *= $scope.videoWidth
        x -= $scope.imageWidth / 2.0
        x += $scope.left
        y *= $scope.videoWidth * (9.0/16.0)
        y -= $scope.imageHeight / 2.0
        $scope.css.top = ""+y+"px"
        $scope.css.left = ""+x+"px"

      angular.element($window).bind 'resize', ->
        $scope.initializeWindowSize()
        $scope.$apply()
        
      $scope.setupFrames()
      $scope.initializeWindowSize()
      $scope.posInterval = $interval($scope.newPos, 30)
      
      $scope.$on "destroy", ->
        $interval.cancel($scope.posInterval)
  }
    
irunner.directive "irHighlightHoverArea", ($window) ->
  return {
    template: '<div ng-style="css"><h5 class="sci-fi" ng-show="!selectedInjury" ng-bind="childText" ng-style="childCss"></h4></div>'
    restrict: 'E'
    scope: {
      injuries: "=injuries"
      selectedInjury: "=selected"
      clickedAnywhere: "=clickedAnywhere"
      hvInjuries: "=hvInjuries"
    }
    controller: ($scope, $element) ->
      $scope.css = {
        position: "fixed"
        width: "10%" 
        left: "45%"
      }
      
      $scope.childCss = {
        position: "fixed"
        left: "55%"
      }
      
      $scope.childText = ""
      
      $element.bind "mousedown", (event) ->
        regionNo = Math.floor((event.pageY / $scope.windowHeight)*$scope.regions.length)
        console.log(regionNo, $scope.regions[regionNo])
        $scope.hvInjuries = $scope.regions[regionNo]
        $scope.showNumbers = false;
        $scope.clickedAnywhere = true;
        $scope.$apply()
        
      $element.bind "mousemove", (event) ->
        regionNo = Math.floor((event.pageY / $scope.windowHeight)*$scope.regions.length)
        if $scope.regions[regionNo].length > 0
          if $scope.regions[regionNo].length == 1
            $scope.childText = "1 Injury Associated With This Area"
          else
            $scope.childText = $scope.regions[regionNo].length + " Injuries Associated With This Area"
          $scope.childCss.top = (regionNo / $scope.regions.length) * $scope.windowHeight + 15 + "px"
        else
          $scope.childText = ""
        $scope.$apply()
        
      $element.bind "mouseleave", (event) ->
        $scope.childText = ""
        $scope.$apply()
      
      $scope.findY = (highlight) ->
        frames = (getFrame(highlight.coordinates, degree) for degree in [0..359])
        return frames[Math.floor(highlight.start)].y
      
      $scope.initializeWindowSize = ->
        $scope.windowWidth  = $window.innerWidth
        $scope.windowHeight = $scope.windowWidth * (9.0/16.0)
        $scope.regionTop = $scope.windowHeight * .1
        $scope.regionHeight = $scope.windowHeight * .9
      
        $scope.css.top = $scope.regionTop + "px"
        $scope.css.height = $scope.regionHeight + "px"
        
        $scope.regions = []
        for i in [0..15]
          $scope.regions.push([])
        
        for injury in $scope.injuries
          if injury.hoverable
            if injury.sections and injury.sections.length > 0
              for section in injury.sections
                $scope.regions[section].push(injury)
            else
              for highlight in injury.highlights
                regionNo = Math.floor($scope.findY(highlight) * $scope.regions.length)
                if injury not in $scope.regions[regionNo]
                  $scope.regions[regionNo].push(injury)

      angular.element($window).bind 'resize', ->
        $scope.initializeWindowSize()
        $scope.$apply()
        
      $scope.initializeWindowSize()
  }
  
irunner.directive 'fitToScreen', ($window) ->
  ($scope) ->
    $scope.initializeWindowSize = ->
      videoRatio = 16.0 / 9.0
      screenRatio = $window.innerWidth / $window.innerHeight 
      if screenRatio > videoRatio
        $scope.height = $window.innerHeight
        $scope.width = $scope.height * videoRatio
        $scope.left = ($window.innerWidth - $scope.width) / 2.0
      else
        $scope.height = $window.innerWidth / videoRatio
        $scope.width = $window.innerWidth
        $scope.left = 0
        
      $scope.fitStyle = {
        position: 'fixed'
        left: $scope.left
        width: $scope.width
        height: $scope.height
      }

    $scope.initializeWindowSize()

    angular.element($window).bind 'resize', ->
      $scope.initializeWindowSize()
      $scope.$apply()

