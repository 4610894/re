let rvCurrentArea = 'area-home';
let savedDatesByArea = {
  selic: null,
  rv: null
};

function calcularDatasPadraoRV() {
  const dates = [...new Set(rawDataRV.map(d => d.dateStr).filter(Boolean))].sort();
  if (!dates.length) return null;

  const minDate = parseSmartDateRV(dates[0]);
  const maxDate = parseSmartDateRV(dates[dates.length - 1]);
  const diffDias = Math.round((maxDate - minDate) / 86400000);

  let bStart, bEnd, cStart, cEnd;
  if (diffDias <= 30) {
    // Se a base tiver até 30 dias, divide ao meio (2ª metade = Base, 1ª metade = Comparação)
    const midIdx = Math.floor(dates.length / 2);
    cStart = dates[0];
    cEnd   = dates[Math.max(0, midIdx - 1)];
    bStart = dates[midIdx];
    bEnd   = dates[dates.length - 1];
  } else {
    bEnd = new Date(maxDate);
    bStart = new Date(maxDate);
    bStart.setDate(bStart.getDate() - 14);
    if (bStart < minDate) bStart.setTime(minDate.getTime());

    cEnd = new Date(bStart);
    cEnd.setDate(cEnd.getDate() - 1);
    cStart = new Date(cEnd);
    cStart.setDate(cStart.getDate() - 14);
    if (cStart < minDate) cStart.setTime(minDate.getTime());

    bStart = toYMDRV(bStart);
    bEnd   = toYMDRV(bEnd);
    cStart = toYMDRV(cStart);
    cEnd   = toYMDRV(cEnd);
  }

  return { i1: bStart, f1: bEnd, i2: cStart, f2: cEnd, min: dates[0], max: dates[dates.length - 1] };
}

function lerDatasFiltrosTopo() {
  return {
    i1: document.getElementById('dataInicio1')?.value || '',
    f1: document.getElementById('dataFim1')?.value || '',
    i2: document.getElementById('dataInicio2')?.value || '',
    f2: document.getElementById('dataFim2')?.value || ''
  };
}

function aplicarDatasFiltrosTopo(cfg) {
  if (!cfg) return;
  const set = (id, val) => { const el = document.getElementById(id); if (el && val) el.value = val; };
  set('dataInicio1', cfg.i1);
  set('dataFim1', cfg.f1);
  set('dataInicio2', cfg.i2);
  set('dataFim2', cfg.f2);
}

function sincronizarDatasArea(areaId) {
  const saindoDeRV = rvCurrentArea === 'area-rv';
  const entrandoEmRV = areaId === 'area-rv';

  if (entrandoEmRV && !saindoDeRV) {
    // Salva as datas atuais (SELIC) antes de aplicar as datas de RV
    savedDatesByArea.selic = lerDatasFiltrosTopo();
    if (!savedDatesByArea.rv && rawDataRV.length) {
      savedDatesByArea.rv = calcularDatasPadraoRV();
    }
    aplicarDatasFiltrosTopo(savedDatesByArea.rv);
    atualizarDashboardRV();
  } else if (!entrandoEmRV && saindoDeRV) {
    // Salva o período que o usuário deixou em RV e restaura SELIC
    savedDatesByArea.rv = lerDatasFiltrosTopo();
    aplicarDatasFiltrosTopo(savedDatesByArea.selic);
    if (typeof atualizarDashboardGlobal === 'function') {
      atualizarDashboardGlobal();
    }
  }

  rvCurrentArea = areaId;
}
