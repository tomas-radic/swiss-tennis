$(document).on('turbolinks:load', function() {
  $('.reloading-page').change(function() {
    var targetUrl = $(this).data('url') +
        '?' +
        $(this).data('param-name') +
        '_id=' +
        $(this).val();
    location.href = targetUrl;
  });

  $('.element-enabler').change(function() {
    var button = $('#' + $(this).data('element-id'));
    $(button).prop('disabled', !$(this).is(":checked"));
  });
});
