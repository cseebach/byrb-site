'use strict';

training = angular.module('training', [ 
  'ngRoute',
  "ngScrollbar"
])

training.service "programs", ->
  return window.programs

training.directive "raceTime" , ->
  timeDuration = /(^[0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2}$)|(^[0-9]{1,2}:[0-9]{1,2}$)/

  durationToSeconds = (durationString) ->
    splits = durationString.split(':')
    [hours, minutes, seconds] = [0, 0, 0]
    if splits.length == 2
      [minutes, seconds] = splits
    else
      [hours, minutes, seconds] = splits
    return parseInt(hours) * 3600 + parseInt(minutes) * 60 + parseInt(seconds)

  return {
    require: 'ngModel'
    link: (scope, elm, attrs, ctrl) ->
      ctrl.$parsers.push (viewValue) ->
        if timeDuration.exec(viewValue)
          ctrl.$setValidity("raceTime", true)
          return durationToSeconds(viewValue)
        else
          ctrl.$setValidity("raceTime", false)
          return null
      ctrl.$parsers.push (viewValue) ->
        if viewValue > parseInt(attrs.maxRaceTime)
          ctrl.$setValidity("maxRaceTime", false)
          return null
        else
          ctrl.$setValidity("maxRaceTime", true)
          return viewValue
  }

window.planDetailController = ($scope) ->

  $scope.raceTypes = [
    {id:1,  name:"1500"}
    {id:2,  name:"Mile"}
    {id:3,  name:"3K"}
    {id:4,  name:"8K"}
    {id:5,  name:"10K"}
    {id:6,  name:"12K"}
    {id:7,  name:"15K"}
    {id:8,  name:"10 Mile"}
    {id:9,  name:"20K"}
    {id:10,  name:"Half Marathon"}
  ]

  $scope.getPlanID = () ->
    if $scope.planDetailForm.$valid
      return window.toBase32($scope.getPlanBinary())
    return undefined

  bPad = (number, length) ->
    asString = number.toString(2)
    return window.pad(asString, length)

  $scope.getPlanBinary = () ->

    binary = bPad($scope.age, 7)
    binary += bPad($scope.currentMileage, 8)
    binary += bPad($scope.goalMileage, 8)
    binary += bPad(($scope.raceType or {id:0}).id, 4)
    binary += bPad($scope.currentTime, 14)
    binary += bPad($scope.goalTime, 14)
    return binary

