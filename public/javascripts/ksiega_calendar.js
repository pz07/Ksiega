/**
 *  Zestaw funkcji do wykorzystania przy wstawianiu kalendarzy do systemu Edumatic.
 *  Kalendarz budowany jest na bazie biblioteki YUI (http://developer.yahoo.com/yui)
 *
 *  Wymagania:
 *    - import skryptow: yahoo-dom-event.js, calendar-min.js, container_core-min.js, element-beta-min.js, button-min.js (kolejnosc istotna)
 *    - na stronie powinien znajdowac sie JEDEN formularz (w chwili obecnej nie sa obslugiwane widoki z wieloma formularzami) z elementem
 *      typu text o nazwie podanej jako argument funkcji createCalendar (w przypadku braku formularza nalezy nadac polu edycyjnemu
 *		id rowne nazwa_pola_formularza + "Input"). Ponadto miejsce 'podczepienia' kalendarza powinno otrzymac
 *      id zlozone ze stringow nazwa_pola_formularza (podana jako argument funkcji createCalendar) oraz 'Calendar'
 *
 *  Utworzenie kalendarza odbywa sie poprzez wywolanie funkcji createCalendar z argumentami:
 *    - calendarId - nazwa pola formularza, do ktorego beda wpisywane daty,
 *    - label - napis przycisku otwierajacego kalendarz,
 *   -  buttonStyle - opcjonalnie styl przycisku.
 *
 *  Autor: Pawel Zieba
 */

/*
 * zdarzenie klikniecia na przycisk. wyswietla kalendarz
 */
function displayCalendar(calendarId, calMenu, submitFunction) {
    var fieldName = calendarId;
	
    calMenu.setBody("&#32;");
    calMenu.body.id = "calendarcontainer";
    calMenu.render(getContainerId(calendarId));
    calMenu.align();
    
    var oCalendar = new YAHOO.widget.Calendar("buttoncalendar", calMenu.body.id);	
	oCalendar.cfg.setProperty("DATE_FIELD_DELIMITER", "-");
	
	oCalendar.cfg.setProperty("MDY_DAY_POSITION", 1);
	oCalendar.cfg.setProperty("MDY_MONTH_POSITION", 2);
	oCalendar.cfg.setProperty("MDY_YEAR_POSITION", 3);
	
	oCalendar.cfg.setProperty("MD_DAY_POSITION", 1);
	oCalendar.cfg.setProperty("MD_MONTH_POSITION", 2);
	
	// Date labels for Polish locale
	oCalendar.cfg.setProperty("MONTHS_SHORT",   ["Sty", "Lut", "Mar", "Kwi", "Maj", "Cze", "Lip", "Sie", "Wrz", "Pa\u017a", "Lis", "Gru"]);
	oCalendar.cfg.setProperty("MONTHS_LONG",    ["Stycze\u0144", "Luty", "Marzec", "Kwiecie\u0144", "Maj", "Czerwiec", "Lipiec", "Sierpie\u0144", "Wrzesie\u0144", "Pa\u017adziernik", "Listopad", "Grudzie\u0144"]);
	oCalendar.cfg.setProperty("WEEKDAYS_1CHAR", ["N", "P", "W", "\u015a", "C", "P", "S"]);
	oCalendar.cfg.setProperty("WEEKDAYS_SHORT", ["Ni", "Po", "Wt", "\u015ar", "Cz", "Pi", "So"]);
	oCalendar.cfg.setProperty("WEEKDAYS_MEDIUM",["Nie", "Pon", "Wto", "\u015aro", "Czw", "Pi\u0105", "Sob"]);
	oCalendar.cfg.setProperty("WEEKDAYS_LONG",  ["Niedziela", "Poniedzia\u0142ek", "Wtorek", "\u015Aroda", "Czwartek", "Pi\u0105tek", "Sobota"]);
	    
    oCalendar.render();
	
    oCalendar.changePageEvent.subscribe(function () {
        window.setTimeout(function () {
            calMenu.show();
        }, 0);
    });


    oCalendar.selectEvent.subscribe(function (p_sType, p_aArgs) {
        var aDate;
        if (p_aArgs) {
        	aDate = p_aArgs[0][0];
        	var data = null;
			
			if (aDate[2] < 10) {
        		data = '0' + aDate[2] + '-';
        	} else {
        		data = aDate[2] + '-';
        	}

        	if (aDate[1] < 10) {
        		data = data + '0' + aDate[1] + '-';
        	} else {
        		data = data + aDate[1] + '-';
        	}        	
			
			var data = data + aDate[0];

			
			submitFunction(data);
		}        
    });
}
 
function getContainerId(calendarId){
	return calendarId+'Calendar';
}
 
 /**
 * tworzenie przycisku kalendarza o podanym id (musi byc unikalne)
 */
function createCalendarButton(calendarId, label, buttonStyle, submitFunction){
	    var oCalendarMenu = new YAHOO.widget.Overlay(calendarId+'menu');
		
	    var oButton = new YAHOO.widget.Button({ 
                                            type: "menu", 
                                            id: calendarId, 
                                            label: label, 
                                            menu: oCalendarMenu, 
                                            container: getContainerId(calendarId),
                                            menuclassname: (buttonStyle ? buttonStyle : 'menubutton') });

		var eventData = new Array();
		eventData["calendarId"] = calendarId;
		eventData["oCalendarMenu"] = oCalendarMenu;
		eventData["submitFunction"] = submitFunction;

		oButton.on("click", onCalendarButtonClick, eventData);
		return oButton;
}

function onCalendarButtonClick(e, eventData){
	var submitFunction = eventData["submitFunction"];
	var menu = eventData["oCalendarMenu"];
	displayCalendar(eventData["calendarId"], menu, function(data){
		submitFunction(data);
		menu.hide();
	});
	this.unsubscribe("click", onCalendarButtonClick);	
}

/**
 * tworzenie kalendarza
 */
function createCalendar(calendarId, submitFunction){
	var oCalendarMenu = new YAHOO.widget.Panel(calendarId+'menu');
	displayCalendar(calendarId, oCalendarMenu, submitFunction);
}
 