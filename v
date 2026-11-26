// --- NAVEGAÇÃO DE VISÕES (Sub-abas) ---
function openTab(tabId) {
  const currentArea = event.currentTarget.closest('.area-content');
  currentArea.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
  currentArea.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));

  document.getElementById(tabId).classList.add('active');
  event.currentTarget.classList.add('active');

  const viewNames = {
    'tab-vol-intradiario': 'Volume de Operações',
    'tab-fin': 'Financeiro',
    'tab-gestores': 'Top Gestores',
    'tab-corretoras': 'Top Corretoras',
    'tab-leadtime': 'Leadtime (SLA)',
    'tab-canceladas': 'Operações Canceladas',
    'tab-natureza': 'Natureza',
    'tab-heatmap': 'Heatmap',
    'tab-qualidade': 'Qualidade',
    // Visões RV
    'tab-rv-vol-intradiario': 'Volume de Operações',
    'tab-rv-financeiro': 'Financeiro por Horário',
    'tab-rv-gestores': 'Top Gestores',
    'tab-rv-corretoras': 'Top Corretoras',
    'tab-rv-leadtime': 'Leadtime (SLA)',
    'tab-rv-canceladas': 'Operações Canceladas',
    'tab-rv-natureza': 'Natureza & Mercados',
    'tab-rv-heatmap': 'Heatmap',
    'tab-rv-clientes': 'Clientes & Títulos',
    'tab-rv-qualidade': 'Qualidade & Corte',
    'tab-rv-ranking': 'Ranking Operacional'
  };

  const currentAreaId = currentArea.id;
  const areaNames = {
    'area-selic': 'SELIC',
    'area-rv': 'Renda Variável',
    'area-cetip': 'CETIP',
    'area-futuros': 'Futuros',
    'area-mrv': 'Margem RV',
    'area-md': 'Margem Dinheiro',
    'area-termo': 'Termo'
  };
  updateBreadcrumb(areaNames[currentAreaId] || 'Dashboard', viewNames[tabId]);

  if (tabId.startsWith('tab-rv-') && typeof renderActiveTabRV === 'function') {
    renderActiveTabRV(tabId);
  }
}
