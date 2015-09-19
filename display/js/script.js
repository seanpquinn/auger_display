// external js: masonry.pkgd.min.js

$(document).ready( function() {

  $('.grid').masonry({
    itemSelector: '.grid-item',
    columnWidth: 180,
    isFitWidth: true
  });
  
});
