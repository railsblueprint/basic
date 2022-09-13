import jQuery from 'jquery';
window.$ = window.jQuery = jQuery;

var $document = $(document);

$.turbo = {
    version: '2.1.0',
    isReady: false,
    use: function(load, fetch) {
        return $document.off('.turbo').on("" + load + ".turbo", this.onLoad).on("" + fetch + ".turbo", this.onFetch);
    },
    addCallback: function(callback) {
        if ($.turbo.isReady) {
            callback($);
        }
        return $document.on('turbo:ready', function() {
            return callback($);
        });
    },
    onLoad: function() {
        $.turbo.isReady = true;
        return $document.trigger('turbo:ready');
    },
    onFetch: function() {
        $.turbo.isReady = false;
        return true;
    },
    register: function() {
        $(this.onLoad);
        return $.fn.ready = this.addCallback;
    }
};

$.turbo.register();

$.turbo.use('turbo:load', 'turbo:before-fetch-request');

document.addEventListener("turbo:frame-missing", function(event) {
    if (event.detail.response.redirected) {
        event.preventDefault()
        event.detail.visit(event.detail.response);
    }
})


// Keeps scroll position of certain elements between navigations, usefull for long sidebar with scroll
var scrollPositions = {};

document.addEventListener("turbo:before-render", function(){
    document.querySelectorAll("[data-turbo-keep-scroll]").forEach(function(element){
        scrollPositions[element.id] = element.scrollTop;
    });
});

document.addEventListener("turbo:render", function(){
    document.querySelectorAll("[data-turbo-keep-scroll]").forEach(function(element){
        element.scrollTop = scrollPositions[element.id];
    });
});

export default $;

