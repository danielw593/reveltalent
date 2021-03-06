'use strict';

angular.module('app.controllers', [])

# overall control
.controller('AppCtrl', [
    '$scope', '$rootScope'
    ($scope, $rootScope) ->
        $window = $(window)

        $scope.main =
            brand: 'Revel Talent'
            name: 'Dan Weiner' # those which uses i18n directive can not be replaced for now.


        $scope.pageTransitionOpts = [
            name: 'Fade up'
            class: 'animate-fade-up'
        ,
            name: 'Scale up'
            class: 'ainmate-scale-up'
        ,
            name: 'Slide in from right'
            class: 'ainmate-slide-in-right'
        ,
            name: 'Flip Y'
            class: 'animate-flip-y'
        ]

        $scope.admin =
            layout: 'wide'                                  # 'boxed', 'wide'
            menu: 'horizontal'                                # 'horizontal', 'vertical'
            fixedHeader: true                               # true, false
            fixedSidebar: true                              # true, false
            pageTransition: $scope.pageTransitionOpts[0]    # unlimited, check out "_animation.scss"

        $scope.$watch('admin', (newVal, oldVal) ->
            # manually trigger resize event to force morris charts to resize, a significant performance impact, enable for demo purpose only
            # if newVal.menu isnt oldVal.menu || newVal.layout isnt oldVal.layout
            #      $window.trigger('resize')

            if newVal.menu is 'horizontal' && oldVal.menu is 'vertical'
                 $rootScope.$broadcast('nav:reset')
                 return
            if newVal.fixedHeader is false && newVal.fixedSidebar is true
                if oldVal.fixedHeader is false && oldVal.fixedSidebar is false
                    $scope.admin.fixedHeader = true
                    $scope.admin.fixedSidebar = true
                if oldVal.fixedHeader is true && oldVal.fixedSidebar is true
                    $scope.admin.fixedHeader = false
                    $scope.admin.fixedSidebar = false
                return
            if newVal.fixedSidebar is true
                $scope.admin.fixedHeader = true
            if newVal.fixedHeader is false
                $scope.admin.fixedSidebar = false

            return
        , true)

        $scope.color =
            primary:        '#5B90BF'   # rgba(91,144,191,1)
            success:        '#A3BE8C'   # rgba(163,190,140,1)
            info:           '#B48EAD'   # rgba(180,142,173,1)
            infoAlt:        '#AB7967'   # rgba(171,121,121,1)
            warning:        '#EBCB8B'   # rgba(235,203,139,1)
            danger:         '#BF616A'   # rgba(191,97,106,1)
            gray:           '#DCDCDC'
])

.controller('HeaderCtrl', [
    '$scope'
    ($scope) ->
])

.controller('NavContainerCtrl', [
    '$scope'
    ($scope) ->
])
.controller('NavCtrl', [
    '$scope',
    ($scope) ->
        # init
])

.controller('DashboardCtrl', [
    '$scope'
    ($scope) ->

])
