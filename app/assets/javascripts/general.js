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

  $('.btn-dbl-confirm').click(function() {
    $(this).hide();
    $(this).next().show();
  });

  $('.span-dbl-confirm .btn-cancel-confirmation').click(function() {
    var span_dbl_confirm = $(this).parent();
    var btn_dbl_confirm = $(span_dbl_confirm).prev();

    $(span_dbl_confirm).hide();
    $(btn_dbl_confirm).show();
  });

  $('.js-filter').on('keyup search', function() {
    var searchedText = filterableText($(this).val());
    var tableRows = $('.' + $(this).data('target') + ' > tr');

    tableRows.each(function() {
      var currentRow = $(this);
      var showCurrentRow = false;

      if (searchedText.length >= 2) {
        $(currentRow).find('.js-filterable').each(function () {
          var cellText = filterableText($(this).text());

          if (cellText.indexOf(searchedText) >= 0) {
            showCurrentRow = true;
            return false; // breaks out
          }
        });
      } else {
        showCurrentRow = true;
      }

      if (showCurrentRow) {
        $(currentRow).show();
      } else {
        $(currentRow).hide();
      }
    });
  });

  // Activate bootstrap tooltips
  $('[data-toggle="tooltip"]').tooltip();

  colorizeAmounts();
});

function filterableText(text) {
  text = text.toLowerCase();
  text = text.normalize("NFD").replace(/[\u0300-\u036f]/g, "");

  return text;
}

function colorizeAmounts() {
  $('.colored-amount').each(function() {
    var content = $(this).text();
    var amount = parseFloat(content.replace(',', '.'));

    $(this).removeClass('text-success');
    $(this).removeClass('text-danger');

    if (amount > 0.0) {
      $(this).addClass('text-success');
    } else if (amount < 0.0) {
      $(this).addClass('text-danger');
    }
  });
}
