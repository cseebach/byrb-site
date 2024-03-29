// Generated by CoffeeScript 1.7.1
(function() {
  'use strict';
  var training;

  training = angular.module('training', ['ngRoute', "ngScrollbar"]);

  training.service("programs", function() {
    return window.programs;
  });

  training.directive("raceTime", function() {
    var durationToSeconds, timeDuration;
    timeDuration = /(^[0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2}$)|(^[0-9]{1,2}:[0-9]{1,2}$)/;
    durationToSeconds = function(durationString) {
      var hours, minutes, seconds, splits, _ref;
      splits = durationString.split(':');
      _ref = [0, 0, 0], hours = _ref[0], minutes = _ref[1], seconds = _ref[2];
      if (splits.length === 2) {
        minutes = splits[0], seconds = splits[1];
      } else {
        hours = splits[0], minutes = splits[1], seconds = splits[2];
      }
      return parseInt(hours) * 3600 + parseInt(minutes) * 60 + parseInt(seconds);
    };
    return {
      require: 'ngModel',
      link: function(scope, elm, attrs, ctrl) {
        ctrl.$parsers.push(function(viewValue) {
          if (timeDuration.exec(viewValue)) {
            ctrl.$setValidity("raceTime", true);
            return durationToSeconds(viewValue);
          } else {
            ctrl.$setValidity("raceTime", false);
            return null;
          }
        });
        return ctrl.$parsers.push(function(viewValue) {
          if (viewValue > parseInt(attrs.maxRaceTime)) {
            ctrl.$setValidity("maxRaceTime", false);
            return null;
          } else {
            ctrl.$setValidity("maxRaceTime", true);
            return viewValue;
          }
        });
      }
    };
  });

  window.planDetailController = function($scope) {
    var bPad;
    $scope.raceTypes = [
      {
        id: 1,
        name: "1500"
      }, {
        id: 2,
        name: "Mile"
      }, {
        id: 3,
        name: "3K"
      }, {
        id: 4,
        name: "8K"
      }, {
        id: 5,
        name: "10K"
      }, {
        id: 6,
        name: "12K"
      }, {
        id: 7,
        name: "15K"
      }, {
        id: 8,
        name: "10 Mile"
      }, {
        id: 9,
        name: "20K"
      }, {
        id: 10,
        name: "Half Marathon"
      }
    ];
    $scope.getPlanID = function() {
      if ($scope.planDetailForm.$valid) {
        return window.toBase32($scope.getPlanBinary());
      }
      return void 0;
    };
    bPad = function(number, length) {
      var asString;
      asString = number.toString(2);
      return window.pad(asString, length);
    };
    return $scope.getPlanBinary = function() {
      var binary;
      binary = bPad($scope.age, 7);
      binary += bPad($scope.currentMileage, 8);
      binary += bPad($scope.goalMileage, 8);
      binary += bPad(($scope.raceType || {
        id: 0
      }).id, 4);
      binary += bPad($scope.currentTime, 14);
      binary += bPad($scope.goalTime, 14);
      return binary;
    };
  };

}).call(this);

//# sourceMappingURL=app.map
