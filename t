import streamlit as st
import pandas as pd
import numpy as np
import plotly.graph_objects as go
from datetime import date

# ==========================================
# CONFIGURAÇÃO DA PÁGINA
# ==========================================
st.set_page_config(
    page_title="Saúde da Operação | Monitoramento Operacional",
    page_icon="📊",
    layout="wide",
    initial_sidebar_state="expanded"
)

# ==========================================
# ESTILIZAÇÃO CSS (TEMA DARK NAVY FIEL AO VÍDEO)
# ==========================================
st.markdown("""
<style>
    /* Fundo principal e tipografia */
    .stApp {
        background: radial-gradient(circle at 50% 10%, #0d1b38 0%, #060b19 60%, #040711 100%);
        color: #F8FAFC;
        font-family: 'Inter', 'Segoe UI', sans-serif;
    }
    .block-container {
        padding-top: 1.2rem !important;
        padding-bottom: 2rem !important;
        max-width: 98% !important;
    }

    /* Barra lateral */
    section[data-testid="stSidebar"] {
        background-color: #050A18 !important;
        border-right: 1px solid #162442 !important;
        width: 90px !important;
    }

    /* Cabeçalho Principal */
    .top-badge {
        color: #38BDF8;
        font-size: 0.72rem;
        font-weight: 700;
        letter-spacing: 1.5px;
        text-transform: uppercase;
        margin-bottom: 2px;
    }
    .main-title {
        font-size: 2.1rem;
        font-weight: 800;
        color: #FFFFFF;
        margin: 0;
        line-height: 1.15;
    }
    .main-subtitle {
        color: #94A3B8;
        font-size: 0.88rem;
        margin-top: 4px;
        margin-bottom: 8px;
    }
    .breadcrumb {
        display: inline-block;
        background: #0D182E;
        border: 1px solid #1E325C;
        border-radius: 6px;
        padding: 4px 12px;
        font-size: 0.78rem;
        color: #94A3B8;
        margin-bottom: 14px;
    }
    .breadcrumb span {
        color: #38BDF8;
        font-weight: 600;
    }

    /* Containers e Cards de KPI */
    .kpi-card {
        background: linear-gradient(145deg, #0D172B 0%, #091020 100%);
        border: 1px solid #1C2E52;
        border-radius: 12px;
        padding: 18px 20px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35);
        position: relative;
        min-height: 118px;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
    }
    .kpi-card:hover {
        border-color: #2B4C8C;
    }
    .kpi-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        color: #94A3B8;
        font-size: 0.72rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.8px;
    }
    .kpi-info-icon {
        color: #475569;
        font-size: 0.8rem;
        cursor: help;
    }
    .kpi-value {
        font-size: 2.0rem;
        font-weight: 800;
        color: #FFFFFF;
        margin: 6px 0 4px 0;
        letter-spacing: -0.5px;
    }
    .kpi-sub {
        font-size: 0.76rem;
        color: #38BDF8;
        font-weight: 500;
    }

    /* Card de Visão Consolidada (Tela Inicial) */
    .consolidated-banner {
        background: linear-gradient(180deg, rgba(13, 23, 43, 0.75) 0%, rgba(9, 16, 32, 0.9) 100%);
        border: 1px solid #1C2E52;
        border-radius: 14px;
        padding: 70px 30px;
        text-align: center;
        margin-top: 24px;
        margin-bottom: 24px;
    }
    .consolidated-banner h2 {
        color: #FFFFFF;
        font-size: 1.5rem;
        font-weight: 800;
        letter-spacing: 0.8px;
        margin-bottom: 8px;
    }
    .consolidated-banner p {
        color: #94A3B8;
        font-size: 0.95rem;
        margin: 0;
    }

    /* Títulos de Seção */
    .section-title {
        font-size: 1.05rem;
        font-weight: 700;
        color: #F1F5F9;
        margin: 22px 0 12px 0;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    /* Estilização da Tabela HTML customizada (Top 100) */
    .custom-table-container {
        background: #0B1325;
        border: 1px solid #1C2E52;
        border-radius: 12px;
        padding: 16px;
        margin-top: 18px;
        overflow-x: auto;
    }
    table.ops-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 0.80rem;
        color: #E2E8F0;
    }
    table.ops-table th {
        text-align: left;
        padding: 10px 12px;
        color: #64748B;
        font-size: 0.70rem;
        text-transform: uppercase;
        letter-spacing: 0.8px;
        border-bottom: 1px solid #1E293B;
    }
    table.ops-table td {
        padding: 9px 12px;
        border-bottom: 1px solid rgba(30, 41, 59, 0.5);
    }
    table.ops-table tr:hover {
        background-color: rgba(56, 189, 248, 0.05);
    }
    .status-ok {
        color: #34D399;
        font-weight: 600;
    }
    .status-delay {
        color: #FB7185;
        font-weight: 600;
    }

    /* Ajuste de inputs do Streamlit para o tema escuro */
    div[data-baseweb="select"] > div,
    div[data-baseweb="input"] > div {
        background-color: #070E1C !important;
        border-color: #1E325C !important;
        color: #F8FAFC !important;
        border-radius: 8px !important;
    }
    label[data-testid="stWidgetLabel"] p {
        font-size: 0.68rem !important;
        font-weight: 700 !important;
        color: #94A3B8 !important;
        text-transform: uppercase !important;
        letter-spacing: 0.6px !important;
    }
    /* Botões de abas (Radio horizontal transformado em Pílulas) */
    div[role="radiogroup"] {
        background: #091122;
        padding: 6px;
        border-radius: 10px;
        border: 1px solid #1A2B4C;
        gap: 6px;
        overflow-x: auto;
    }
    div[role="radiogroup"] label {
        background: transparent;
        border: 1px solid transparent;
        padding: 6px 14px !important;
        border-radius: 7px !important;
        transition: all 0.2s;
    }
    div[role="radiogroup"] label[data-checked="true"] {
        background: #1D4ED8 !important;
        border-color: #38BDF8 !important;
        color: white !important;
    }
</style>
""", unsafe_allow_html=True)


# ==========================================
# FUNÇÃO DE COMPONENTES VISUAIS
# ==========================================
def render_kpi(title: str, value: str, subtitle: str, sub_color: str = "#38BDF8"):
    st.markdown(f"""
    <div class="kpi-card">
        <div class="kpi-header">
            <span>{title}</span>
            <span class="kpi-info-icon" title="Indicador monitorado na janela selecionada">ⓘ</span>
        </div>
        <div class="kpi-value">{value}</div>
        <div class="kpi-sub" style="color: {sub_color};">{subtitle}</div>
    </div>
    """, unsafe_allow_html=True)


# ==========================================
# SIMULAÇÃO DE DADOS (OU LEITURA DE CSV)
# ==========================================
@st.cache_data
def get_simulated_data():
    hours = [f"{h:02d}:00" for h in range(8, 22)]

    # Curvas horárias Sem Termo (Pico às 09:00 e onda às 16:00-18:00)
    rec_sem_termo_base = [1200, 15862, 6200, 2400, 2100, 2300, 2500, 3100, 5800, 9400, 8200, 4800, 2100, 800]
    rec_sem_termo_comp = [1100, 14900, 5800, 2200, 2000, 2100, 2400, 2900, 5200, 8700, 7600, 4400, 1900, 700]

    aloc_sem_termo_base = [600, 4200, 8500, 3100, 2300, 2200, 2400, 2800, 4900, 8600, 9100, 5900, 2600, 950]
    aloc_sem_termo_comp = [550, 3900, 7900, 2950, 2150, 2050, 2250, 2600, 4600, 8100, 8500, 5400, 2400, 850]

    liq_sem_termo_base = [300, 1800, 5400, 3400, 2500, 2100, 2300, 2600, 4100, 7200, 8800, 6700, 3200, 1100]
    liq_sem_termo_comp = [280, 1650, 5100, 3200, 2350, 1950, 2150, 2450, 3900, 6800, 8300, 6200, 2900, 1000]

    # Curvas horárias Termo (Concentração forte às 16:00 - 18:00)
    rec_termo_base = [120, 450, 380, 290, 260, 310, 420, 890, 5349, 4800, 2400, 980, 250, 103]
    rec_termo_comp = [100, 410, 350, 270, 240, 290, 390, 820, 4900, 4400, 2150, 890, 220, 90]

    aloc_termo_base = [80, 320, 410, 310, 270, 290, 380, 740, 3900, 5100, 2900, 1150, 310, 120]
    liq_termo_base = [50, 210, 380, 330, 280, 270, 340, 620, 2800, 4600, 3300, 1400, 390, 140]

    # Curva Financeira por Horário (em Bilhões R$)
    fin_base = [420, 3650, 1100, 480, 620, 1850, 920, 780, 1950, 1120, 890, 1540, 410, 120]
    fin_comp = [390, 3420, 1020, 450, 590, 1710, 880, 730, 1810, 1050, 830, 1420, 380, 105]

    # Curvas de Leadtime (min)
    lt_total_base = [110, 18, 92, 68, 49, 44, 48, 36, 32, 34, 28, 22, 26, 15]
    lt_total_comp = [98, 22, 85, 62, 52, 47, 50, 39, 35, 36, 30, 25, 28, 18]

    lt_app_base = [32, 8, 24, 18, 14, 12, 13, 10, 9, 11, 8, 7, 8, 5]
    lt_app_comp = [29, 9, 22, 17, 15, 13, 14, 11, 10, 12, 9, 8, 9, 6]

    lt_cp_base = [78, 10, 68, 50, 35, 32, 35, 26, 23, 23, 20, 15, 18, 10]
    lt_cp_comp = [69, 13, 63, 45, 37, 34, 36, 28, 25, 24, 21, 17, 19, 12]

    df_hourly = pd.DataFrame({
        "hora": hours,
        "rec_st_base": rec_sem_termo_base,
        "rec_st_comp": rec_sem_termo_comp,
        "aloc_st_base": aloc_sem_termo_base,
        "aloc_st_comp": aloc_sem_termo_comp,
        "liq_st_base": liq_sem_termo_base,
        "liq_st_comp": liq_sem_termo_comp,
        "rec_t_base": rec_termo_base,
        "rec_t_comp": rec_termo_comp,
        "aloc_t_base": aloc_termo_base,
        "liq_t_base": liq_termo_base,
        "fin_base": fin_base,
        "fin_comp": fin_comp,
        "lt_total_base": lt_total_base,
        "lt_total_comp": lt_total_comp,
        "lt_app_base": lt_app_base,
        "lt_app_comp": lt_app_comp,
        "lt_cp_base": lt_cp_base,
        "lt_cp_comp": lt_cp_comp,
    })

    # Ranking Top 15 Gestores
    gestores = [
        "MIDDLE_ASSET", "SANTANDER_ASSET", "ITAU_ASSET", "BRADESCO_ASSET",
        "BTG_GESTAO", "KINEA_INVEST", "XP_ASSET", "SAFRA_ASSET",
        "VERDE_ASSET", "KAPITALO", "LEGACY_CAPITAL", "ABSOLUTE_INVEST",
        "SPX_CAPITAL", "VINLAND_CAPITAL", "ARX_INVEST"
    ]
    vol_gestores = [42500, 14200, 11800, 8900, 6400, 5100, 4300, 3800, 3100, 2400, 1950, 1600, 1400, 1100, 950]
    pos16_gestores = [18400, 6200, 5100, 3900, 2800, 2100, 1850, 1600, 1200, 980, 840, 710, 620, 510, 430]
    fin_gestores = [6850.4, 1420.8, 1180.5, 890.2, 640.1, 510.7, 430.9, 380.4, 310.2, 240.6, 195.3, 160.8, 140.2, 110.5, 98.6]
    atraso_gestores = [48.2, 44.5, 41.0, 38.7, 36.4, 34.1, 31.8, 29.5, 27.9, 26.1, 24.8, 23.2, 21.9, 20.4, 19.1]

    df_gestores = pd.DataFrame({
        "rank": [f"#{i+1}" for i in range(15)],
        "gestor": gestores,
        "volume": vol_gestores,
        "pos16": pos16_gestores,
        "financeiro_bi": fin_gestores,
        "atraso_min": atraso_gestores
    })

    # Ranking Corretoras
    corretoras = [
        "ITAU", "UBS", "BRADESCO", "JP MORGAN", "CITIBANK",
        "BTG PACTUAL", "SANTANDER", "GOLDMAN", "MORGAN", "XP",
        "BOFA", "CREDIT", "SAFRA", "GENIAL", "TULLETT"
    ]
    vol_corretoras = [16500, 13200, 11400, 9800, 8900, 8200, 7400, 6800, 6100, 5400, 4800, 3900, 3100, 2500, 2000]
    atraso_corretoras = [52.4, 49.1, 46.8, 43.2, 39.7, 37.5, 35.8, 34.2, 31.9, 29.4, 27.6, 25.1, 23.8, 21.4, 19.8]

    df_corretoras = pd.DataFrame({
        "rank": [f"#{i+1}" for i in range(15)],
        "corretora": corretoras,
        "volume": vol_corretoras,
        "atraso_min": atraso_corretoras
    })

    # Amostra Top 100 Operações
    np.random.seed(42)
    n_rows = 100
    df_sample = pd.DataFrame({
        "CORRETORA": np.random.choice(corretoras[:8], size=n_rows),
        "GESTOR": np.random.choice(gestores[:6], size=n_rows, p=[0.45, 0.15, 0.12, 0.10, 0.10, 0.08]),
        "ATIVO": np.random.choice(["Ações Vista", "Termo Ações", "BDR", "ETF", "Opções"], size=n_rows, p=[0.65, 0.15, 0.08, 0.07, 0.05]),
        "VALOR (R$)": [f"R$ {val:,.2f}".replace(",", "X").replace(".", ",").replace("X", ".") for val in np.random.uniform(1_500_000, 280_000_000, size=n_rows)],
        "STATUS": np.random.choice(["Liquidado no Prazo", "Atraso Operacional"], size=n_rows, p=[0.68, 0.32]),
        "DATA/HORA": [f"2026-01-{np.random.randint(10, 30):02d} {np.random.randint(9, 19):02d}:{np.random.randint(0, 59):02d}:00" for _ in range(n_rows)]
    })

    return df_hourly, df_gestores, df_corretoras, df_sample


df_hourly, df_gestores, df_corretoras, df_sample = get_simulated_data()


# ==========================================
# BARRA LATERAL (NAVEGAÇÃO PRINCIPAL)
# ==========================================
with st.sidebar:
    st.markdown("### 🌐")
    nav_section = st.radio(
        "Menu",
        options=["🏠 Início", "📈 Operação", "🛡️ Risco", "💼 Gestores", "🏦 Corretoras", "🔍 Análises", "⚙️ Config"],
        index=1,
        label_visibility="collapsed"
    )
    st.markdown("---")
    uploaded_csv = st.file_uploader("📂 CSV", type=["csv"], help="Carregue a base operacional (.csv)")


# ==========================================
# CABEÇALHO E FILTROS GLOBAIS
# ==========================================
col_head_left, col_head_right = st.columns([4, 1])
with col_head_left:
    st.markdown('<div class="top-badge">MONITORAMENTO OPERACIONAL • B3 & MERCADO</div>', unsafe_allow_html=True)
    st.markdown('<h1 class="main-title">Saúde da Operação</h1>', unsafe_allow_html=True)
    st.markdown('<div class="main-subtitle">Liquidação, risco, eficiência e comportamento operacional em visão executiva.</div>', unsafe_allow_html=True)

with col_head_right:
    st.write("")
    c_btn1, c_btn2 = st.columns(2)
    with c_btn1:
        st.button("🔄 Redefinir", use_container_width=True)
    with c_btn2:
        st.download_button(
            "📥 Exportar CSV",
            data=df_sample.to_csv(index=False).encode("utf-8"),
            file_name="base_operacional.csv",
            mime="text/csv",
            use_container_width=True
        )

# Barra de Filtros de Período Base vs Comparação
with st.container():
    f1, f2, f3, f4, f5, f6, f7, f8, f9 = st.columns([1.1, 1.1, 1.3, 1.3, 0.9, 1.1, 1.1, 1.3, 1.3])
    with f1:
        dt_base_ini = st.date_input("PERÍODO BASE - INÍCIO", value=date(2026, 1, 1))
    with f2:
        dt_base_fim = st.date_input("PERÍODO BASE - FIM", value=date(2026, 1, 31))
    with f3:
        gestor_base = st.selectbox("GESTOR (BASE)", ["Todos os Gestores"] + df_gestores["gestor"].tolist())
    with f4:
        escopo_base = st.selectbox("ESCOPO (BASE)", ["Todos (Pré + Câmara)", "Apenas Pré-Matching", "Apenas Câmara"])
    with f5:
        st.write("")
        ativar_comp = st.checkbox("ATIVAR COMPARAÇÃO", value=True)
    with f6:
        dt_comp_ini = st.date_input("PERÍODO COMP. - INÍCIO", value=date(2025, 12, 1), disabled=not ativar_comp)
    with f7:
        dt_comp_fim = st.date_input("PERÍODO COMP. - FIM", value=date(2025, 12, 31), disabled=not ativar_comp)
    with f8:
        gestor_comp = st.selectbox("GESTOR (COMPARAÇÃO)", ["Todos os Gestores"] + df_gestores["gestor"].tolist(), disabled=not ativar_comp)
    with f9:
        escopo_comp = st.selectbox("ESCOPO (COMPARAÇÃO)", ["Todos (Pré + Câmara)", "Apenas Pré-Matching", "Apenas Câmara"], disabled=not ativar_comp)


# ==========================================
# FUNÇÃO AUXILIAR DE LAYOUT PLOTLY
# ==========================================
def apply_dark_plotly_layout(fig, height=340, show_legend=True):
    fig.update_layout(
        template="plotly_dark",
        paper_bgcolor="rgba(11, 19, 37, 0.85)",
        plot_bgcolor="rgba(11, 19, 37, 0.0)",
        height=height,
        margin=dict(l=20, r=20, t=42, b=20),
        showlegend=show_legend,
        legend=dict(
            orientation="h",
            yanchor="bottom",
            y=1.02,
            xanchor="center",
            x=0.5,
            font=dict(size=11, color="#CBD5E1")
        ),
        xaxis=dict(
            showgrid=True,
            gridcolor="rgba(30, 41, 59, 0.45)",
            zeroline=False,
            tickfont=dict(color="#94A3B8", size=11)
        ),
        yaxis=dict(
            showgrid=True,
            gridcolor="rgba(30, 41, 59, 0.45)",
            zeroline=False,
            tickfont=dict(color="#94A3B8", size=11)
        )
    )
    return fig


def render_bottom_table(df):
    st.markdown('<div class="section-title">📋 Amostra de Resultados Base (Top 100)</div>', unsafe_allow_html=True)
    rows_html = ""
    for _, row in df.head(25).iterrows():
        status_cls = "status-ok" if "Prazo" in row["STATUS"] else "status-delay"
        rows_html += f"""
        <tr>
            <td><b>{row['CORRETORA']}</b></td>
            <td>{row['GESTOR']}</td>
            <td>{row['ATIVO']}</td>
            <td>{row['VALOR (R$)']}</td>
            <td class="{status_cls}">{row['STATUS']}</td>
            <td>{row['DATA/HORA']}</td>
        </tr>
        """
    st.markdown(f"""
    <div class="custom-table-container">
        <table class="ops-table">
            <thead>
                <tr>
                    <th>CORRETORA</th>
                    <th>GESTOR</th>
                    <th>ATIVO</th>
                    <th>VALOR (R$)</th>
                    <th>STATUS</th>
                    <th>DATA/HORA</th>
                </tr>
            </thead>
            <tbody>
                {rows_html}
            </tbody>
        </table>
    </div>
    """, unsafe_allow_html=True)


# ==========================================
# ROTEAMENTO: TELA INICIAL (VISÃO CONSOLIDADA)
# ==========================================
if nav_section == "🏠 Início":
    st.markdown('<div class="breadcrumb">Início &nbsp;›&nbsp; <span>Visão Consolidada</span></div>', unsafe_allow_html=True)

    k1, k2, k3 = st.columns(3)
    with k1:
        render_kpi("VOLUME GLOBAL PROCESSADO", "110.332", "Operações no período")
    with k2:
        render_kpi("FINANCEIRO GLOBAL MOVIMENTADO", "R$ 13550,2 bi", "Acumulado")
    with k3:
        render_kpi("SAÚDE DO SLA GLOBAL", "68%", "Aderência à Janela", "#34D399")

    st.markdown("""
    <div class="consolidated-banner">
        <h2>VISÃO CONSOLIDADA</h2>
        <p>Selecione uma área específica no menu lateral ou superior para acessar os detalhamentos e gráficos horários.</p>
    </div>
    """, unsafe_allow_html=True)

# ==========================================
# ROTEAMENTO: OPERAÇÃO (E SUB-ABAS HORIZONTAIS)
# ==========================================
else:
    sub_tab = st.radio(
        "Sub-abas da Operação",
        options=[
            "Volume de Operações",
            "Financeiro Movimentado",
            "Top Gestores",
            "Top Corretoras",
            "Leadtime (SLA)",
            "Alocação x Batimento",
            "Rejeições",
            "Cadastros",
            "Risco",
            "Cadeia",
            "Preditivo (SLA)",
            "Ranking Operacional"
        ],
        horizontal=True,
        label_visibility="collapsed"
    )

    st.markdown(f'<div class="breadcrumb">Início &nbsp;›&nbsp; Operação &nbsp;›&nbsp; <span>{sub_tab}</span></div>', unsafe_allow_html=True)

    # ------------------------------------------
    # ABA 1: VOLUME DE OPERAÇÕES
    # ------------------------------------------
    if sub_tab == "Volume de Operações":
        # 1.1 Sem Termo
        st.markdown('<div class="section-title">📊 Volume de Operações Recepcionadas — Sem Termo</div>', unsafe_allow_html=True)
        c1, c2, c3, c4 = st.columns(4)
        with c1:
            render_kpi("PICO DE RECEPÇÃO (PRÉ) - SEM TERMO", "09:00", "Média de 15.862 ops neste horário")
        with c2:
            render_kpi("HORÁRIO MAIS CRÍTICO - SEM TERMO", "17:00", "Maior concentração pós-16h", "#F59E0B")
        with c3:
            render_kpi("MÉDIA DIÁRIA APÓS 16H - SEM TERMO", "7.145", "Total de 142.895 no mês")
        with c4:
            render_kpi("TOTAL DO PERÍODO - SEM TERMO", "92.998", "Operações")

        st.markdown('<div class="section-title">📈 Distribuição Horária - Sem Termo</div>', unsafe_allow_html=True)
        curvas_st = st.multiselect(
            "Séries visíveis (Sem Termo):",
            ["Recepção (Início)", "Alocação", "Liquidação"],
            default=["Recepção (Início)", "Alocação", "Liquidação"],
            label_visibility="collapsed"
        )

        fig_st = go.Figure()
        # Banda P25-P75 simulada
        p75 = [v * 1.15 for v in df_hourly["rec_st_base"]]
        p25 = [v * 0.85 for v in df_hourly["rec_st_base"]]
        fig_st.add_trace(go.Scatter(
            x=df_hourly["hora"], y=p75, mode="lines", line=dict(width=0),
            showlegend=False, hoverinfo="skip"
        ))
        fig_st.add_trace(go.Scatter(
            x=df_hourly["hora"], y=p25, mode="lines", line=dict(width=0),
            fill="tonexty", fillcolor="rgba(56, 189, 248, 0.12)",
            name="Faixa P25 - P75"
        ))

        if "Recepção (Início)" in curvas_st:
            fig_st.add_trace(go.Scatter(
                x=df_hourly["hora"], y=df_hourly["rec_st_base"], mode="lines+markers",
                name="Recepção (Início) - Período Base",
                line=dict(color="#38BDF8", width=3, shape="spline")
            ))
            if ativar_comp:
                fig_st.add_trace(go.Scatter(
                    x=df_hourly["hora"], y=df_hourly["rec_st_comp"], mode="lines",
                    name="Recepção (Início) - Comparação",
                    line=dict(color="#38BDF8", width=2, dash="dot", shape="spline")
                ))

        if "Alocação" in curvas_st:
            fig_st.add_trace(go.Scatter(
                x=df_hourly["hora"], y=df_hourly["aloc_st_base"], mode="lines+markers",
                name="Alocação - Período Base",
                line=dict(color="#F59E0B", width=2.5, shape="spline")
            ))
            if ativar_comp:
                fig_st.add_trace(go.Scatter(
                    x=df_hourly["hora"], y=df_hourly["aloc_st_comp"], mode="lines",
                    name="Alocação - Comparação",
                    line=dict(color="#F59E0B", width=1.8, dash="dot", shape="spline")
                ))

        if "Liquidação" in curvas_st:
            fig_st.add_trace(go.Scatter(
                x=df_hourly["hora"], y=df_hourly["liq_st_base"], mode="lines+markers",
                name="Liquidação - Período Base",
                line=dict(color="#FB7185", width=2.5, shape="spline")
            ))
            if ativar_comp:
                fig_st.add_trace(go.Scatter(
                    x=df_hourly["hora"], y=df_hourly["liq_st_comp"], mode="lines",
                    name="Liquidação - Comparação",
                    line=dict(color="#FB7185", width=1.8, dash="dot", shape="spline")
                ))

        st.plotly_chart(apply_dark_plotly_layout(fig_st, height=340), use_container_width=True)

        # 1.2 Termo
        st.markdown('<div class="section-title">📊 Volume de Operações Recepcionadas — Termo</div>', unsafe_allow_html=True)
        t1, t2, t3, t4 = st.columns(4)
        with t1:
            render_kpi("PICO DE RECEPÇÃO (PRÉ) - TERMO", "16:00", "Média de 5.349 ops neste horário")
        with t2:
            render_kpi("HORÁRIO MAIS CRÍTICO - TERMO", "17:00", "Maior concentração pós-16h", "#F59E0B")
        with t3:
            render_kpi("MÉDIA DIÁRIA APÓS 16H - TERMO", "1.309", "Total de 26.178 no mês")
        with t4:
            render_kpi("TOTAL DO PERÍODO - TERMO", "17.002", "Operações")

        st.markdown('<div class="section-title">📈 Distribuição Horária - Termo</div>', unsafe_allow_html=True)
        fig_t = go.Figure()
        fig_t.add_trace(go.Scatter(
            x=df_hourly["hora"], y=df_hourly["rec_t_base"], mode="lines+markers",
            name="Recepção (Termo) - Período Base",
            line=dict(color="#38BDF8", width=3, shape="spline"),
            fill="tozeroy", fillcolor="rgba(56, 189, 248, 0.10)"
        ))
        fig_t.add_trace(go.Scatter(
            x=df_hourly["hora"], y=df_hourly["aloc_t_base"], mode="lines+markers",
            name="Alocação (Termo) - Período Base",
            line=dict(color="#F59E0B", width=2.5, shape="spline")
        ))
        fig_t.add_trace(go.Scatter(
            x=df_hourly["hora"], y=df_hourly["liq_t_base"], mode="lines+markers",
            name="Liquidação (Termo) - Período Base",
            line=dict(color="#FB7185", width=2.5, shape="spline")
        ))
        if ativar_comp:
            fig_t.add_trace(go.Scatter(
                x=df_hourly["hora"], y=df_hourly["rec_t_comp"], mode="lines",
                name="Recepção (Termo) - Comparação",
                line=dict(color="#94A3B8", width=2, dash="dot", shape="spline")
            ))
        st.plotly_chart(apply_dark_plotly_layout(fig_t, height=320), use_container_width=True)

        # 1.3 Visão Consolidada de Recepção e Liquidação (2 Gráficos de Barra Horizontais)
        st.markdown('<div class="section-title">🏆 Visão Consolidada de Recepção e Liquidação</div>', unsafe_allow_html=True)
        b_left, b_right = st.columns(2)
        df_g_sorted = df_gestores.iloc[::-1]

        with b_left:
            st.caption("**Top 15 Gestores (Volume Total)**")
            fig_bar1 = go.Figure(go.Bar(
                x=df_g_sorted["volume"],
                y=df_g_sorted["rank"] + " " + df_g_sorted["gestor"],
                orientation="h",
                marker=dict(color="#38BDF8"),
                text=df_g_sorted["volume"],
                textposition="outside"
            ))
            st.plotly_chart(apply_dark_plotly_layout(fig_bar1, height=420, show_legend=False), use_container_width=True)

        with b_right:
            st.caption("**Gestores que mais batem após 16h**")
            fig_bar2 = go.Figure(go.Bar(
                x=df_g_sorted["pos16"],
                y=df_g_sorted["rank"] + " " + df_g_sorted["gestor"],
                orientation="h",
                marker=dict(color="#2DD4BF"),
                text=df_g_sorted["pos16"],
                textposition="outside"
            ))
            st.plotly_chart(apply_dark_plotly_layout(fig_bar2, height=420, show_legend=False), use_container_width=True)

        render_bottom_table(df_sample)

    # ------------------------------------------
    # ABA 2: FINANCEIRO MOVIMENTADO
    # ------------------------------------------
    elif sub_tab == "Financeiro Movimentado":
        c1, c2, c3, c4 = st.columns(4)
        with c1:
            render_kpi("PICO FINANCEIRO", "09:00", "Horário de maior concentração")
        with c2:
            render_kpi("MÉDIA DIÁRIA (MOVIMENTADO)", "R$ 1042,3 bi", "No período")
        with c3:
            render_kpi("TOTAL MOVIMENTADO NO PERÍODO", "R$ 13.550.154.350.173,16", "Acumulado Bruto", "#34D399")
        with c4:
            render_kpi("TOTAL DE OPERAÇÕES", "109.999", "Com valor financeiro")

        st.markdown('<div class="section-title">💹 Volume Financeiro por Horário</div>', unsafe_allow_html=True)
        fig_fin = go.Figure()
        fig_fin.add_trace(go.Scatter(
            x=df_hourly["hora"], y=df_hourly["fin_base"],
            mode="lines+markers",
            name="Volume Fin. Médio Período Base (R$ bi)",
            line=dict(color="#10B981", width=3, shape="spline"),
            fill="tozeroy", fillcolor="rgba(16, 185, 129, 0.22)"
        ))
        if ativar_comp:
            fig_fin.add_trace(go.Scatter(
                x=df_hourly["hora"], y=df_hourly["fin_comp"],
                mode="lines",
                name="Volume Fin. Médio Período Comparação (R$ bi)",
                line=dict(color="#F43F5E", width=2, dash="dot", shape="spline")
            ))
        st.plotly_chart(apply_dark_plotly_layout(fig_fin, height=350), use_container_width=True)

        st.markdown('<div class="section-title">🏅 Top 15 Gestores - Volume Financeiro</div>', unsafe_allow_html=True)
        df_g_fin = df_gestores.iloc[::-1]
        fig_fin_bar = go.Figure(go.Bar(
            x=df_g_fin["financeiro_bi"],
            y=df_g_fin["rank"] + " " + df_g_fin["gestor"],
            orientation="h",
            marker=dict(color="#38BDF8"),
            text=[f"R$ {v:,.1f} bi" for v in df_g_fin["financeiro_bi"]],
            textposition="outside"
        ))
        st.plotly_chart(apply_dark_plotly_layout(fig_fin_bar, height=430, show_legend=False), use_container_width=True)

        render_bottom_table(df_sample)

    # ------------------------------------------
    # ABA 3: TOP GESTORES
    # ------------------------------------------
    elif sub_tab == "Top Gestores":
        c1, c2, c3 = st.columns(3)
        with c1:
            render_kpi("GESTOR LÍDER (FINANCEIRO)", "MIDDLE_ASSET", "Maior volume")
        with c2:
            render_kpi("CONCENTRAÇÃO TOP 3", "70%", "Risco de dependência", "#F59E0B")
        with c3:
            render_kpi("TICKET MÉDIO DA LÍDER", "R$ 260,0 mi", "Por operação")

        st.markdown('<div class="section-title">📊 Top Gestores por Financeiro</div>', unsafe_allow_html=True)
        df_g_top = df_gestores.iloc[::-1]
        fig_top_g = go.Figure(go.Bar(
            x=df_g_top["financeiro_bi"] * 1e9,
            y=df_g_top["gestor"],
            orientation="h",
            marker=dict(color="#38BDF8"),
            text=[f"R$ {v:,.1f} bi" for v in df_g_top["financeiro_bi"]],
            textposition="outside"
        ))
        st.plotly_chart(apply_dark_plotly_layout(fig_top_g, height=430, show_legend=False), use_container_width=True)

        render_bottom_table(df_sample)

    # ------------------------------------------
    # ABA 4: TOP CORRETORAS
    # ------------------------------------------
    elif sub_tab == "Top Corretoras":
        c1, c2, c3 = st.columns(3)
        with c1:
            render_kpi("CORRETORA LÍDER (VOLUME)", "ITAÚ", "16.500 ops")
        with c2:
            render_kpi("MARKET SHARE LÍDER (OPERAÇÕES)", "15%", "Participação")
        with c3:
            render_kpi("CORRETORAS ATIVAS NO PERÍODO", "59", "Com movimentação")

        st.markdown('<div class="section-title">🍩 Distribuição por Corretora</div>', unsafe_allow_html=True)
        fig_donut = go.Figure(go.Pie(
            labels=df_corretoras["corretora"],
            values=df_corretoras["volume"],
            hole=0.68,
            textinfo="none",
            marker=dict(colors=[
                "#38BDF8", "#0EA5E9", "#2563EB", "#1D4ED8", "#3B82F6",
                "#60A5FA", "#2DD4BF", "#14B8A6", "#F43F5E", "#FB7185",
                "#F59E0B", "#A855F7", "#6366F1", "#8B5CF6", "#64748B"
            ])
        ))
        fig_donut.update_layout(
            template="plotly_dark",
            paper_bgcolor="rgba(11, 19, 37, 0.85)",
            height=380,
            margin=dict(l=20, r=20, t=30, b=20),
            legend=dict(orientation="v", x=0.72, y=0.5, font=dict(size=12))
        )
        st.plotly_chart(fig_donut, use_container_width=True)

        render_bottom_table(df_sample)

    # ------------------------------------------
    # ABA 5: LEADTIME (SLA)
    # ------------------------------------------
    elif sub_tab == "Leadtime (SLA)":
        f_lt1, f_lt2 = st.columns([2, 3])
        with f_lt1:
            visao_lt = st.selectbox("VISÃO DE LEADTIME", ["Visão Completa (Todos)", "Apenas Leadtime Total", "Leadtime Interno vs Contraparte"])
        with f_lt2:
            st.write("")
            c_chk1, c_chk2, c_chk3 = st.columns(3)
            show_lt_tot = c_chk1.checkbox("Leadtime Total", value=True)
            show_lt_app = c_chk2.checkbox("Leadtime App", value=True)
            show_lt_cp = c_chk3.checkbox("Leadtime Contraparte", value=True)

        if show_lt_tot:
            st.markdown('<div class="section-title">⏱️ Leadtime Total</div>', unsafe_allow_html=True)
            l1, l2, l3, l4 = st.columns(4)
            with l1:
                render_kpi("LEADTIME MÉDIO (TOTAL)", "25.1 min", "Tempo médio ponta a ponta")
            with l2:
                render_kpi("HORÁRIO MAIS CRÍTICO (ATRASO)", "09:00", "Maior gargalo", "#FB7185")
            with l3:
                render_kpi("SLA ATINGIDO (< 30 MIN)", "68%", "Aderência à janela", "#34D399")
            with l4:
                render_kpi("VOLUME DENTRO DO SLA", "109.999", "Operações analisadas")

            fig_lt1 = go.Figure()
            fig_lt1.add_trace(go.Scatter(
                x=df_hourly["hora"], y=df_hourly["lt_total_base"],
                mode="lines+markers", name="Leadtime Total - Período Base (min)",
                line=dict(color="#FB7185", width=3, shape="spline")
            ))
            if ativar_comp:
                fig_lt1.add_trace(go.Scatter(
                    x=df_hourly["hora"], y=df_hourly["lt_total_comp"],
                    mode="lines", name="Leadtime Total - Período Comparação (min)",
                    line=dict(color="#E2E8F0", width=2, dash="dot", shape="spline")
                ))
            st.plotly_chart(apply_dark_plotly_layout(fig_lt1, height=290), use_container_width=True)

        if show_lt_app:
            st.markdown('<div class="section-title">⚡ Leadtime App</div>', unsafe_allow_html=True)
            a1, a2, a3, a4 = st.columns(4)
            with a1:
                render_kpi("LEADTIME MÉDIO (APP)", "7.0 min", "Processamento interno")
            with a2:
                render_kpi("HORÁRIO MAIS CRÍTICO (APP)", "08:00", "Pico de latência")
            with a3:
                render_kpi("SLA INTERNO (< 10 MIN)", "88%", "Eficiência de sistema", "#34D399")
            with a4:
                render_kpi("% DO LEADTIME TOTAL", "30%", "Peso na operação")

            fig_lt2 = go.Figure()
            fig_lt2.add_trace(go.Scatter(
                x=df_hourly["hora"], y=df_hourly["lt_app_base"],
                mode="lines+markers", name="Leadtime App - Período Base (min)",
                line=dict(color="#38BDF8", width=3, shape="spline")
            ))
            if ativar_comp:
                fig_lt2.add_trace(go.Scatter(
                    x=df_hourly["hora"], y=df_hourly["lt_app_comp"],
                    mode="lines", name="Leadtime App - Período Comparação (min)",
                    line=dict(color="#94A3B8", width=2, dash="dot", shape="spline")
                ))
            st.plotly_chart(apply_dark_plotly_layout(fig_lt2, height=290), use_container_width=True)

        if show_lt_cp:
            st.markdown('<div class="section-title">🤝 Leadtime Contraparte</div>', unsafe_allow_html=True)
            p1, p2, p3, p4 = st.columns(4)
            with p1:
                render_kpi("LEADTIME MÉDIO (CONTRAPARTE)", "18.2 min", "Tempo externo / mercado")
            with p2:
                render_kpi("HORÁRIO MAIS CRÍTICO (CONTRAPARTE)", "10:00", "Maior demora externa", "#F59E0B")
            with p3:
                render_kpi("SLA CONTRAPARTE (< 20 MIN)", "71%", "Eficiência externa")
            with p4:
                render_kpi("% DO LEADTIME TOTAL", "70%", "Peso na operação")

            fig_lt3 = go.Figure()
            fig_lt3.add_trace(go.Scatter(
                x=df_hourly["hora"], y=df_hourly["lt_cp_base"],
                mode="lines+markers", name="Leadtime Contraparte - Período Base (min)",
                line=dict(color="#60A5FA", width=3, shape="spline")
            ))
            if ativar_comp:
                fig_lt3.add_trace(go.Scatter(
                    x=df_hourly["hora"], y=df_hourly["lt_cp_comp"],
                    mode="lines", name="Leadtime Contraparte - Período Comparação (min)",
                    line=dict(color="#94A3B8", width=2, dash="dot", shape="spline")
                ))
            st.plotly_chart(apply_dark_plotly_layout(fig_lt3, height=290), use_container_width=True)

        # Origem e Impacto dos Atrasos
        st.markdown('<div class="section-title">🔥 Origem e Impacto dos Atrasos</div>', unsafe_allow_html=True)
        st.selectbox("AGRUPAMENTO / ESCOPO DE ATRASO", ["Todas as Operações", "Apenas Operações Fora do SLA (> 30 min)"])

        col_at1, col_at2 = st.columns(2)
        df_g_at = df_gestores.iloc[::-1]
        df_c_at = df_corretoras.iloc[::-1]

        with col_at1:
            st.caption("**Top 15 Gestores Impactados**")
            fig_at1 = go.Figure(go.Bar(
                x=df_g_at["atraso_min"],
                y=df_g_at["rank"] + " " + df_g_at["gestor"],
                orientation="h",
                marker=dict(color=df_g_at["atraso_min"], colorscale="YlOrRd"),
                text=[f"{v:.1f} min" for v in df_g_at["atraso_min"]],
                textposition="outside"
            ))
            st.plotly_chart(apply_dark_plotly_layout(fig_at1, height=420, show_legend=False), use_container_width=True)

        with col_at2:
            st.caption("**Top 15 Corretoras que Mais Atrasam**")
            fig_at2 = go.Figure(go.Bar(
                x=df_c_at["atraso_min"],
                y=df_c_at["rank"] + " " + df_c_at["corretora"],
                orientation="h",
                marker=dict(color=df_c_at["atraso_min"], colorscale="Hot"),
                text=[f"{v:.1f} min" for v in df_c_at["atraso_min"]],
                textposition="outside"
            ))
            st.plotly_chart(apply_dark_plotly_layout(fig_at2, height=420, show_legend=False), use_container_width=True)

        render_bottom_table(df_sample)

    else:
        st.info(f"A aba **{sub_tab}** está estruturada no menu. Confirme os detalhes abaixo para preenchermos os indicadores específicos desta visão.")
