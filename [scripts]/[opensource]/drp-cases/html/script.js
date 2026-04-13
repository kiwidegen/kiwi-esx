$(document).ready(function() {
    $("#container").hide();

    window.addEventListener("message", function(event) {
        var data = event.data;

        if (data && data.type === "ui") {
            $(".raffle-roller-container").empty().css("margin-left", "0px");
            $("#container").show();
            rollRaffle(data.data, data.img, data.win);
        } else if (data && data.type === "off") {
            $("#container").hide();
            $(".raffle-roller-container").empty();
        }
    });

    function rollRaffle(items, imgSource, winItem) {
        for (var n = 1; n < 50; n++) {
            var rand = a(1, 10);
            var index = a(1, items.length);
            var element;

            if (n !== 46) {
                var item = items[index] || {};
                var label = item.label || "Unknown Reward";
                var itemId = getItemId(item);
                var imageSrc = itemId ? (imgSource + itemId + '.png') : (imgSource + "default.png");
                element = '<div id="CaseOpenCard' + n + '" class="case_item"><div class="bottom-skin' + (item.tier || 1) + '"><b>' + label + '</b></div><img src="' + imageSrc + '" class="case_item_image"></div>';
            } else {
                var winLabel = winItem.label || "Unknown Reward";
                var winItemId = getItemId(winItem);
                var winImageSrc = winItemId ? (imgSource + winItemId + '.png') : (imgSource + "default.png");
                element = '<div id="CaseOpenCard' + n + '" class="case_item"><div class="bottom-skin' + (winItem.tier || 1) + '"><b>' + winLabel + '</b></div><img src="' + winImageSrc + '" class="case_item_image"><img src="' + s + '" class="case_item_shadow"></div>';
                i = " " + winLabel;
            }
            $(element).appendTo(".raffle-roller-container");
        }

        e.play();
        setTimeout(function() {
            $(".raffle-roller-container").css("transition", "margin-left 7s ease");
            $(".raffle-roller-container").css("margin-left", "-5416px");
            setTimeout(function() {
                $("#CaseOpenCard46").addClass("winning-item");
                $.post("http://drp-cases/drp-cases:NUIoff", JSON.stringify({}));
            }, 7300);
        }, 700);
    }

    function getItemId(obj) {
        if (obj.item) return obj.item;
        if (obj.weapon) return obj.weapon;
        if (obj.money) return "money";
        if (obj.black_money) return "black_money";
        return null;
    }

    var e = document.getElementById("audio1") || { play: function() {} };
    var i = "", s = "";
    function a(min, max) {
        return Math.floor(Math.random() * (max - min)) + min;
    }
});