<%!
    def list2str(claim):
        # more human-friendly and avoid "u'" prefix for unicode strings in list
        if isinstance(claim, list):
            claim = ", ".join(claim)
        if claim.startswith('['):
            claim = claim[1:]
        if claim.startswith('\''):
            claim = claim[1:]
        if claim.endswith(']'):
            claim = claim[:-1]
        if claim.endswith('\''):
            claim = claim[:-1]
        return claim
%>

<%inherit file="base.mako"/>

<%block name="head_title">Consent</%block>
<%block name="page_header">${_("Your consent is required to continue.")}</%block>
<%block name="extra_inputs">
    <input type="hidden" name="state" value="${ state }">
</%block>

## ${_(consent_question)}

<div class="list-group">
    <p class="small">
      <b>${requester_name}</b> 
         ${_("would like to access the following attributes:")}
    </p>
    % for attribute in released_claims:
        <div class="checkbox list-group-item">
          <h4 class="list-group-item-heading">
          </h4>
            <label><input type="checkbox"
                 name="${attribute.lower()}"
                 value="${released_claims[attribute] | list2str}"
                 checked>
                 &nbsp;<span>${_(attribute).capitalize()}</span>:&nbsp;
                 <span>${released_claims[attribute] | list2str}</span>
            </label>
        </div>
    % endfor

    % if locked_claims:
      <div class="btn btn-link"
           onclick="$('#locked').toggleClass('hidden');">
        <h4 class="small">${_("Click to see what else is sent with your consent")}</h4>
        <div class="hidden list-group-item" id="locked">
        % for attribute in locked_claims:
          <span> ${_(attribute).capitalize()}</span>:&nbsp;
          <span>${locked_claims[attribute] | list2str}</span>
        % endfor
        </div>
      </div>
    % endif
    <div class="row"><hr/></div>

    <div class="row">
      <div class="col-md-10">
        <h5>${_("For how long do you give consent to this service?")}</h5>
      </div>
      <div class="col-md-2 aligh-right sp-col-2">
        <form name="allow_consent" id="allow_consent_form"
              action="/save_consent" method="GET">
        <select name="month" id="month">
            % for month in months:
                <option value="${month}">
                    <span>${month}</span> <span> ${_("months")}</span>
                </option>
            % endfor
        </select>
      </div>
    </div>

    <div class="row clearfix"><br/></div>
    <div class="btn-block">
      <input name="Yes" value="${_('OK, accept')}" id="submit_ok"
             type="submit" class="btn btn-primary">
      <input name="No" value="${_('No, cancel')}" id="submit_deny"
             type="submit" class="btn btn-warning">
     </div>
      <input type="hidden" id="attributes" name="attributes"/>
      <input type="hidden" id="consent_status" name="consent_status"/>
    ${extra_inputs()}
    </form>
</div>

<script>
    $('input:checked').each(function () {
        if (!${select_attributes.lower()}) {
            $(this).removeAttr("checked")
        }
    });

    $('#allow_consent_form').submit(function (ev) {
        ev.preventDefault(); // to stop the form from submitting

        var attributes = [];
        $('input:checked').each(function () {
            attributes.push(this.name);
        });

        var consent_status = $('#consent_status');

        var status = $("input[type=submit][clicked=true]").attr("name");
        consent_status.val(status);

        if (attributes.length == 0) {
            consent_status.val("No");
            alert("${_('No attributes where selected which equals no consent where given')}");
        }

        % for attr in locked_claims:
            attributes.push("${attr}");
        % endfor
        $('#attributes').val(attributes);

        this.submit(); // If all the validations succeeded
    });

    $("form input[type=submit]").click(function () {
        $("input[type=submit]", $(this).parents("form")).removeAttr("clicked");
        $(this).attr("clicked", "true");
    });
</script>
