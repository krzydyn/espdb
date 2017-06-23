function storageAvailable(type) {
    try {
        var storage = window[type], x = '__storage_test__';
        storage.setItem(x, x);
        storage.removeItem(x);
        return true;
    }
    catch(e) {
        return e instanceof DOMException && (
            // everything except Firefox
            e.code === 22 ||
            // Firefox
            e.code === 1014 ||
            // test name field too, because code might not be present
            // everything except Firefox
            e.name === 'QuotaExceededError' ||
            // Firefox
            e.name === 'NS_ERROR_DOM_QUOTA_REACHED') &&
            // acknowledge QuotaExceededError only if there's something already stored
            storage.length !== 0;
    }
}

function saveLocal(key,val) {
/*
	localStorage.colorSetting = '#a4509b'; //method 1
	localStorage['colorSetting'] = '#a4509b'; //method 2
	localStorage.setItem('colorSetting', '#a4509b');//method 3
*/
	console.log('saving '+key+' as '+val.substring(0,100));
	localStorage.setItem(key,val);
}

function readLocal(key) {
	return localStorage.getItem(key);
}
