.directive "electionMap", ($filter, $location, $rootScope) ->
  restrict: "A"
  templateUrl: "partials/election-map.html"
  link: (scope, element, attrs) ->
    svg = d3.select "#dk_valgkredse"
    tip = d3.tip()
      .attr "class", "map-tip"
      .html (data) ->
        red = $filter('number')(data.red_block_votes_pct, 1)
        blue = $filter('number')(data.blue_block_votes_pct, 1)
        counted = $filter('number')(data.votes_counted_pct, 1)

        html = "<h2 class=\"map-tip-header\">"
        html+= "<div class=\"map-tip-counted\">Optalt: #{counted}%</div>"
        html+= "#{data.name}</h2>"
        html+= "<table class=\"map-tip-table striped\">"
        html+= "<tbody>"

        for party in data.parties
          percent = $filter('number')(party.votes_pct, 1)

          html+= "<tr>"
          html+= "<td><i class=\"partylogo #{party.party_letter}\"></i></td>"
          html+= "<td>#{party.party_name}</td>"
          html+= "<td class=\"number\">#{percent}%</td>"
          html+= "</tr>"

        html+= "</tbody>"
        html+= "</table>"
        html+= "<div class=\"map-tip-block\">"
        html+= "<div class=\"map-tip-red\">#{red}%</div>"
        html+= "<div class=\"map-tip-blue\" style=\"width:#{blue}%\">#{blue}%</div>"
        html+= "</div>"

        return html

    classes = (block, pct) ->
      if block is "red"
        return "red" if pct >= 99.9
        return "light-red" if pct >= 50
        return "lighter-red"
      else
        return "blue" if pct >= 99.9
        return "light-blue" if pct >= 50
        return "lighter-blue"

    render = (data) ->
      for constituency in data
        mapId = constituency.ident.replace "K", "op-kreds-"

        svg.select "##{mapId}"
          .data [constituency]
          .attr "class", (d) -> "map #{classes(d.block_winner, d.votes_counted_pct)}"
          .on "mouseover", (d) ->
            d3.select(this).attr "class", "map selected"

            targetRect = this.getBBox()
            parentRect = element[0].getBoundingClientRect();
            tipDirection = ''
            if targetRect.y > parentRect.height / 2
              tipDirection = 'n'
            else
              tipDirection = 's'
            if targetRect.x > parentRect.width / 2
              tipDirection += 'w'
            else
              tipDirection += 'e'
            tip
              .direction tipDirection
              .show d
          .on "mouseout", (d) ->
            d3.select(this).attr "class", "map #{classes(d.block_winner, d.votes_counted_pct)}"
            tip.hide()
          .on "click", (d) ->
            tip.destroy()
            scope.$apply ->
              $location.path "resultater#{d.path}"

    svg.call tip

    scope.$watchCollection "json.map", (data) ->
      render(data.constituencies) if data
