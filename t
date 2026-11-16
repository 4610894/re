import streamlit as st
import pandas as pd
import numpy as np
import plotly.graph_objects as go
from datetime import date

# ==========================================
# CONFIGURAÇÃO DA PÁGINA
# ==========================================
st.set_page_config(
    page_title="Dashboard v3.0.0 - Saúde da Operação",
    page_icon="📊",
    layout="wide",
    initial_sidebar_state="expanded"
)

# ==========================================
# CSS CUSTOMIZADO (FIEL AO HTML DAS FOTOS)
# ==========================================
st.markdown("""
<style>
    /* Fundo principal em gradiente Dark Navy */
    .stApp {
        background: radial-gradient(circle at 50% 0%, #10213f 0%, #091326 55%, #050b16 100%);
        color: #F8FAFC;
        font-family: 'Inter', 'Segoe UI', sans-serif;
    }
    .block-container {
        padding-top: 1.2rem !important;
        padding-bottom: 2.5rem !important;
        max-width: 97% !important;
    }

    /* Barra Lateral Estreita com Logo CM */
    section[data-testid="stSidebar"] {
        background-color: #060C1A !important;
        border-right: 1px solid #162647 !important;
        width: 105px !important;
        min-width: 105px !important;
    }
    .cm-logo {
        width: 44px;
        height: 44px;
        border-radius: 50%;
        background: linear-gradient(135deg, #38BDF8 0%, #0284C7 100%);
        color: #FFFFFF;
        font-weight: 800;
        font-size: 0.95rem;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 18px auto;
        box-shadow: 0 0 15px rgba(56, 189, 248, 0.45);
    }

    /* Cabeçalho Superior */
    .top-tag {
        color: #94A3B8;
        font-size: 0.68rem;
        font-weight: 800;
        letter-spacing: 1.4px;
        text-transform: uppercase;
        margin-bottom: 2px;
    }
    .page-title {
        font-size: 2.05rem;
        font-weight: 800;
        color: #FFFFFF;
        margin: 0;
        line-height: 1.15;
    }
    .page-subtitle {
        color: #94A3B8;
        font-size: 0.84rem;
        margin-top: 4px;
        margin-bottom: 10px;
    }

    /* Breadcrumb e Status Online */
    .header-bar {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 12px;
    }
    .breadcrumb-box {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 0.78rem;
        color: #94A3B8;
    }
    .bc-pill {
        background: rgba(14, 165, 233, 0.18);
        border: 1px solid rgba(56, 189, 248, 0.45);
        color: #38BDF8;
        font-weight: 700;
        padding: 2px 10px;
        border-radius: 5px;
    }
    .bc-pill-sub {
        background: rgba(148, 163, 184, 0.15);
        border: 1px solid rgba(148, 163, 184, 0.3);
        color: #E2E8F0;
        font-weight: 600;
        padding: 2px 10px;
        border-radius: 5px;
    }
    .status-pills {
        display: flex;
        gap: 10px;
    }
    .status-badge {
        background: #0A1529;
        border: 1px solid #1C315A;
        border-radius: 20px;
        padding: 4px 12px;
        font-size: 0.72rem;
        color: #CBD5E1;
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .dot-green {
        width: 7px;
        height: 7px;
        background-color: #10B981;
        border-radius: 50%;
        display: inline-block;
        box-shadow: 0 0 6px #10B981;
    }

    /* Cards de KPI */
    .kpi-card {
        background: linear-gradient(160deg, #0E1B33 0%, #091224 100%);
        border: 1px solid #1D3561;
        border-top: 2px solid #22D3EE;
        border-radius: 12px;
        padding: 16px 20px;
        box-shadow: 0 6px 20px rgba(0, 0, 0, 0.35);
        min-height: 116px;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
    }
    .kpi-top {
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-size: 0.68rem;
        font-weight: 800;
        color: #CBD5E1;
        letter-spacing: 0.6px;
        text-transform: uppercase;
    }
    .kpi-icon {
        color: #64748B;
        font-size: 0.8rem;
    }
    .kpi-val {
        font-size: 1.95rem;
        font-weight: 800;
        color: #FFFFFF;
        margin: 6px 0 4px 0;
    }
    .kpi-foot {
        font-size: 0.74rem;
        font-weight: 600;
    }

    /* Banner Visão Consolidada (Home) */
    .consolidated-box {
        background: linear-gradient(180deg, rgba(14, 27, 51, 0.75) 0%, rgba(8, 16, 32, 0.9) 100%);
        border: 1px solid #1B3159;
        border-radius: 14px;
        padding: 68px 24px;
        text-align: center;
        margin-top: 20px;
    }
    .consolidated-box h2 {
        color: #FFFFFF;
        font-size: 1.45rem;
        font-weight: 800;
        letter-spacing: 0.8px;
        margin-bottom: 8px;
    }
    .consolidated-box p {
        color: #94A3B8;
        font-size: 0.90rem;
        margin: 0;
    }

    /* Títulos de Seção */
    .sec-title {
        font-size: 1.05rem;
        font-weight: 800;
        color: #FFFFFF;
        margin: 22px 0 12px 0;
    }

    /* Cabeçalho de Container de Gráfico */
    .chart-box-header {
        background: #0C172C;
        border: 1px solid #1C315A;
        border-bottom: none;
        border-radius: 12px 12px 0 0;
        padding: 14px 20px 6px 20px;
        margin-top: 16px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .chart-box-title {
        font-size: 0.90rem;
        font-weight: 700;
        color: #F8FAFC;
    }
    .chart-tag {
        background: rgba(16, 185, 129, 0.14);
        border: 1px solid rgba(16, 185, 129, 0.4);
        color: #34D399;
        font-size: 0.62rem;
        font-weight: 800;
        padding: 3px 9px;
        border-radius: 12px;
        letter-spacing: 0.7px;
        text-transform: uppercase;
    }

    /* Ranking de Barras Horizontais Customizado (Fiel à Foto 4, 7 e 8) */
    .rank-card {
        background: #0B1528;
        border: 1px solid #1C315A;
        border-radius: 12px;
        padding: 18px 20px;
        height: 100%;
    }
    .rank-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: 14px;
    }
    .rank-title {
        font-size: 0.92rem;
        font-weight: 800;
        color: #FFFFFF;
    }
    .rank-sub {
        font-size: 0.75rem;
        color: #94A3B8;
        margin-top: 2px;
    }
    .rank-row {
        display: grid;
        grid-template-columns: 28px 115px 1fr 78px;
        align-items: center;
        gap: 10px;
        padding: 5px 0;
        font-size: 0.75rem;
    }
    .rank-pos {
        color: #64748B;
        font-weight: 700;
    }
    .rank-name {
        color: #E2E8F0;
        font-weight: 700;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    .rank-bar-bg {
        background: rgba(30, 41, 59, 0.55);
        height: 8px;
        border-radius: 6px;
        overflow: hidden;
    }
    .rank-bar-fill-cyan {
        background: linear-gradient(90deg, #38BDF8 0%, #2DD4BF 100%);
        height: 100%;
        border-radius: 6px;
    }
    .rank-bar-fill-amber {
        background: linear-gradient(90deg, #F59E0B 0%, #FEF08A 100%);
        height: 100%;
        border-radius: 6px;
    }
    .rank-val {
        text-align: right;
        color: #F8FAFC;
        font-weight: 700;
    }

    /* Tabela Inferior (Amostra de Pendências Atual - Top 100) */
    .table-card {
        background: #0B1528;
        border: 1px solid #1C315A;
        border-radius: 12px;
        padding: 18px 20px;
        margin-top: 20px;
    }
    table.pend-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 0.78rem;
        margin-top: 10px;
    }
    table.pend-table th {
        text-align: left;
        padding: 10px 12px;
        color: #94A3B8;
        font-size: 0.67rem;
        font-weight: 800;
        text-transform: uppercase;
        letter-spacing: 0.7px;
        border-bottom: 1px solid #1E293B;
    }
    table.pend-table td {
        padding: 10px 12px;
        border-bottom: 1px solid rgba(30, 41, 59, 0.55);
        color: #F1F5F9;
        font-weight: 600;
    }
    .status-pill-devolvida {
        background: rgba(244, 63, 94, 0.16);
        border: 1px solid rgba(244, 63, 94, 0.4);
        color: #FDA4AF;
        padding: 3px 10px;
        border-radius: 6px;
        font-size: 0.72rem;
        font-weight: 700;
        display: inline-block;
    }

    /* Ajustes de Widgets Nativos Streamlit */
    div[data-baseweb="select"] > div,
    div[data-baseweb="input"] > div {
        background-color: #081121 !important;
        border-color: #1D3561 !important;
        color: #F8FAFC !important;
        border-radius: 8px !important;
        font-size: 0.82rem !important;
    }
    label[data-testid="stWidgetLabel"] p {
        font-size: 0.66rem !important;
        font-weight: 800 !important;
        color: #CBD5E1 !important;
        text-transform: uppercase !important;
        letter-spacing: 0.5px !important;
    }
    /* Sub-abas Horizontais estilo Pílula Verde/Teal */
    div[role="radiogroup"] {
        background: #091326;
        padding: 8px 10px;
        border-radius: 10px;
        border: 1px solid #1B3159;
        gap: 6px;
        overflow-x: auto;
    }
    div[role="radiogroup"] label {
        background: #0D1B35 !important;
        border: 1px solid #1E3663 !important;
        padding: 5px 13px !important;
        border-radius: 8px !important;
    }
    div[role="radiogroup"] label[data-checked="true"] {
        background: linear-gradient(90deg, #0D9488 0%, #10B981 100%) !important;
        border-color: #34D399 !important;
        color: #FFFFFF !important;
        font-weight: 700 !important;
    }
</style>
""", unsafe_allow_html=True)


# ==========================================
# COMPONENTES AUXILIARES
# ==========================================
def render_kpi_card(title: str, value: str, footer: str, foot_color: str = "#10B981"):
    st.markdown(f"""
    <div class="kpi-card">
        <div class="kpi-top">
            <span>{title}</span>
            <span class="kpi-icon">ⓘ</span>
        </div>
        <div class="kpi-val">{value}</div>
        <div class="kpi-foot" style="color: {foot_color};">{footer}</div>
    </div>
    """, unsafe_allow_html=True)


def render_horizontal_ranking(title: str, badge: str, items: list, bar_style: str = "cyan", subtitle: str = ""):
    max_val = max(x[1] for x in items) if items else 1
    rows_html = ""
    fill_cls = "rank-bar-fill-cyan" if bar_style == "cyan" else "rank-bar-fill-amber"
    for idx, (name, val, formatted_val) in enumerate(items, 1):
        pct = max(4, int((val / max_val) * 100))
        rows_html += f"""
        <div class="rank-row">
            <span class="rank-pos">#{idx}</span>
            <span class="rank-name">{name}</span>
            <div class="rank-bar-bg"><div class="{fill_cls}" style="width: {pct}%;"></div></div>
            <span class="rank-val">{formatted_val}</span>
        </div>
        """
    sub_html = f'<div class="rank-sub">{subtitle}</div>' if subtitle else ""
    st.markdown(f"""
    <div class="rank-card">
        <div class="rank-header">
            <div>
                <div class="rank-title">{title}</div>
                {sub_html}
            </div>
            <span class="chart-tag">{badge}</span>
        </div>
        {rows_html}
    </div>
    """, unsafe_allow_html=True)


def render_pendencias_table(df_pend: pd.DataFrame):
    rows_html = ""
    for _, r in df_pend.iterrows():
        rows_html += f"""
        <tr>
            <td>{r['id_op']}</td>
            <td>{r['gestor']}</td>
            <td>{r['origem']}</td>
            <td>{r['valor']}</td>
            <td><span class="status-pill-devolvida">{r['status']}</span></td>
            <td>{r['registro']}</td>
        </tr>
        """
    st.markdown(f"""
    <div class="table-card">
        <div class="rank-header" style="margin-bottom: 4px;">
            <div class="rank-title">Amostra de Pendências Atual (Top 100)</div>
            <span class="chart-tag">SMART SAMPLE</span>
        </div>
        <table class="pend-table">
            <thead>
                <tr>
                    <th>ID OPERAÇÃO</th>
                    <th>GESTOR</th>
                    <th>ORIGEM</th>
                    <th>VALOR (R$)</th>
                    <th>STATUS</th>
                    <th>REGISTRO</th>
                </tr>
            </thead>
            <tbody>
                {rows_html}
            </tbody>
        </table>
    </div>
    """, unsafe_allow_html=True)


def style_plotly(fig: go.Figure, height: int = 300):
    fig.update_layout(
        template="plotly_dark",
        paper_bgcolor="#0C172C",
        plot_bgcolor="#0C172C",
        height=height,
        margin=dict(l=35, r=20, t=36, b=30),
        legend=dict(
            orientation="h",
            yanchor="bottom",
            y=1.02,
            xanchor="center",
            x=0.5,
            font=dict(size=11, color="#E2E8F0")
        ),
        xaxis=dict(
            showgrid=True,
            gridcolor="rgba(30, 41, 59, 0.55)",
            zeroline=False,
            tickfont=dict(color="#94A3B8", size=10)
        ),
        yaxis=dict(
            showgrid=True,
            gridcolor="rgba(30, 41, 59, 0.55)",
            zeroline=False,
            tickfont=dict(color="#94A3B8", size=10)
        )
    )
    return fig


# ==========================================
# DADOS SIMULADOS CALIBRADOS COM AS FOTOS
# ==========================================
@st.cache_data
def load_simulated_data():
    hours = [f"{h:02d}:00" for h in range(8, 22)]

    # 1. Curvas Intraday - Volume Sem Termo (Fotos 2 e 3)
    rec_st_base = [60, 2237, 250, 140, 110, 80, 70, 80, 320, 860, 580, 180, 40, 10]
    rec_st_comp = [55, 2180, 230, 160, 120, 75, 520, 140, 480, 840, 550, 150, 35, 8]
    fin_st_base = [10, 40, 180, 220, 180, 90, 60, 110, 360, 910, 640, 240, 50, 12]
    fin_st_comp = [15, 35, 160, 190, 160, 80, 110, 620, 420, 410, 280, 90, 25, 5]

    # 2. Curvas Intraday - Volume Termo (Foto 3)
    rec_t_base = [30, 860, 220, 25, 10, 8, 5, 12, 18, 20, 15, 10, 140, 20]
    rec_t_comp = [40, 1040, 350, 30, 12, 10, 8, 10, 15, 18, 12, 8, 25, 10]
    fin_t_base = [5, 15, 12, 8, 5, 5, 6, 8, 25, 320, 550, 45, 15, 5]
    fin_t_comp = [5, 18, 14, 10, 6, 6, 8, 10, 40, 450, 580, 50, 20, 8]

    # 3. Curvas Intraday - Leadtime (Fotos 6 e 8)
    lt_tot_base = [110.1, 18.0, 98.0, 76.0, 49.0, 45.0, 34.0, 20.0, 11.0, 9.0, 8.0, 7.0, 11.0, 3.0]
    lt_tot_comp = [92.0, 22.0, 128.0, 71.0, 46.0, 39.0, 33.0, 21.0, 23.0, 14.0, 7.0, 13.0, 8.0, 2.0]

    lt_itau_base = [87.0, 2.0, 36.0, 28.0, 23.0, 32.0, 20.0, 6.0, 4.0, 4.0, 3.0, 4.0, 10.0, 2.0]
    lt_itau_comp = [90.0, 1.0, 55.0, 16.0, 20.0, 15.0, 16.0, 12.0, 16.0, 7.0, 4.0, 5.0, 9.0, 1.0]

    lt_cp_base = [23.1, 16.0, 63.9, 52.0, 25.0, 22.0, 21.0, 16.0, 9.0, 11.0, 12.0, 6.0, 2.0, 1.0]
    lt_cp_comp = [2.0, 19.0, 74.0, 56.0, 30.0, 29.0, 22.0, 11.0, 13.0, 17.0, 11.0, 18.0, 1.0, 1.0]

    df_intraday = pd.DataFrame({
        "hora": hours,
        "rec_st_base": rec_st_base, "rec_st_comp": rec_st_comp,
        "fin_st_base": fin_st_base, "fin_st_comp": fin_st_comp,
        "rec_t_base": rec_t_base, "rec_t_comp": rec_t_comp,
        "fin_t_base": fin_t_base, "fin_t_comp": fin_t_comp,
        "lt_tot_base": lt_tot_base, "lt_tot_comp": lt_tot_comp,
        "lt_itau_base": lt_itau_base, "lt_itau_comp": lt_itau_comp,
        "lt_cp_base": lt_cp_base, "lt_cp_comp": lt_cp_comp,
    })

    # Tabela de Pendências (Fotos 4 e 7)
    df_pend = pd.DataFrame([
        {"id_op": "13128567", "gestor": "MIDDLE_ASSET", "origem": "Mercado", "valor": "R$ 3.331.059,48", "status": "Devolvida pelo usuário", "registro": "2026-09-11 09:00"},
        {"id_op": "13128568", "gestor": "MIDDLE_ASSET", "origem": "Mercado", "valor": "R$ 848.359,57", "status": "Devolvida pelo usuário", "registro": "2026-09-11 09:00"},
        {"id_op": "13128569", "gestor": "MIDDLE_ASSET", "origem": "Mercado", "valor": "R$ 2.511.288,12", "status": "Devolvida pelo usuário", "registro": "2026-09-11 09:00"},
        {"id_op": "13128570", "gestor": "MIDDLE_ASSET", "origem": "Mercado", "valor": "R$ 6.189.193,19", "status": "Devolvida pelo usuário", "registro": "2026-09-11 09:00"},
        {"id_op": "13128571", "gestor": "MIDDLE_ASSET", "origem": "Mercado", "valor": "R$ 434.828,79", "status": "Devolvida pelo usuário", "registro": "2026-09-11 09:00"},
        {"id_op": "13128572", "gestor": "MIDDLE_ASSET", "origem": "Mercado", "valor": "R$ 8.517.414,00", "status": "Devolvida pelo usuário", "registro": "2026-09-11 09:00"},
        {"id_op": "13128573", "gestor": "MIDDLE_ASSET", "origem": "Mercado", "valor": "R$ 25.430.083,50", "status": "Devolvida pelo usuário", "registro": "2026-09-11 09:00"},
        {"id_op": "13128574", "gestor": "MIDDLE_ASSET", "origem": "Mercado", "valor": "R$ 9.739.521,39", "status": "Devolvida pelo usuário", "registro": "2026-09-11 09:00"},
        {"id_op": "13142633", "gestor": "MIDDLE_ASSET", "origem": "Mercado", "valor": "R$ 2.266.224,00", "status": "Devolvida pelo usuário", "registro": "2026-09-15 10:00"},
        {"id_op": "13142634", "gestor": "MIDDLE_ASSET", "origem": "Mercado", "valor": "R$ 13.093.699,18", "status": "Devolvida pelo usuário", "registro": "2026-09-15 10:00"},
        {"id_op": "13142635", "gestor": "MIDDLE_ASSET", "origem": "Mercado", "valor": "R$ 9.579.033,96", "status": "Devolvida pelo usuário", "registro": "2026-09-15 10:00"},
    ])

    return df_intraday, df_pend


df_intraday, df_pend = load_simulated_data()


# ==========================================
# BARRA LATERAL ESQUERDA (MENU PRINCIPAL)
# ==========================================
with st.sidebar:
    st.markdown('<div class="cm-logo">CM</div>', unsafe_allow_html=True)
    menu_lateral = st.radio(
        "Navegação",
        options=[
            "◆ Home",
            "● SELIC",
            "◇ CETIP",
            "~ Futuros",
            "△ RV",
            "○ Margem RV",
            "◐ Margem D",
            "◢ Termo"
        ],
        index=0,
        label_visibility="collapsed"
    )


# ==========================================
# CABEÇALHO SUPERIOR E BARRA DE FILTROS
# ==========================================
st.markdown('<div class="top-tag">INSTITUTIONAL OPERATIONS • AI POWERED</div>', unsafe_allow_html=True)
st.markdown('<h1 class="page-title">Saúde da Operação</h1>', unsafe_allow_html=True)
st.markdown('<div class="page-subtitle">Liquidação, risco, eficiência e comportamento operacional em visão executiva.</div>', unsafe_allow_html=True)

# Breadcrumb dinâmico + Status
if "Home" in menu_lateral:
    bc_html = '<div class="breadcrumb-box"><span>Home</span> <span class="bc-pill">Dashboard</span></div>'
    status_html = '<div class="status-pills"><div class="status-badge"><span class="dot-green"></span> Dados consolidados</div></div>'
else:
    bc_html = '<div class="breadcrumb-box"><span>Home</span> <span class="bc-pill">SELIC</span></div>'
    status_html = '<div class="status-pills"><div class="status-badge"><span class="dot-green"></span> Dados consolidados</div><div class="status-badge"><span class="dot-green"></span> Sistema online</div></div>'

st.markdown(f'<div class="header-bar">{bc_html}{status_html}</div>', unsafe_allow_html=True)

# Filtros Globais (Período Base e Período Comparação lado a lado)
col_f_base, col_f_comp = st.columns(2)
with col_f_base:
    with st.container(border=True):
        b1, b2, b3, b4 = st.columns([1.1, 1.1, 1.3, 1.4])
        b1.date_input("■ PERÍODO BASE - INÍCIO", value=date(2026, 9, 1))
        b2.date_input("■ PERÍODO BASE - FIM", value=date(2026, 9, 18))
        b3.selectbox("GESTOR (BASE)", ["Todos os Gestores", "MIDDLE_ASSET", "KINEA", "KAPITINT"])
        b4.selectbox("ORIGEM (BASE)", ["Todas (Itaú + Mercado)", "Itaú", "Mercado"])

with col_f_comp:
    with st.container(border=True):
        c1, c2, c3, c4 = st.columns([1.1, 1.1, 1.3, 1.4])
        c1.date_input("● PERÍODO COMPARAÇÃO - INÍCIO", value=date(2026, 8, 1))
        c2.date_input("● PERÍODO COMPARAÇÃO - FIM", value=date(2026, 8, 18))
        c3.selectbox("GESTOR (COMPARAÇÃO)", ["Todos os Gestores", "MIDDLE_ASSET", "KINEA", "KAPITINT"])
        c4.selectbox("ORIGEM (COMPARAÇÃO)", ["Todas (Itaú + Mercado)", "Itaú", "Mercado"])


# ==========================================
# ROTEAMENTO 1: PÁGINA INICIAL (FOTO 1)
# ==========================================
if "Home" in menu_lateral:
    k1, k2, k3 = st.columns(3)
    with k1:
        render_kpi_card("VOLUME GLOBAL PROCESSADO", "110.332", "Operações no período", "#10B981")
    with k2:
        render_kpi_card("FINANCEIRO GLOBAL MOVIMENTADO", "R$ 13550,2 bi", "Acumulado", "#38BDF8")
    with k3:
        render_kpi_card("SAÚDE DO SLA GLOBAL", "68%", "Aderência < 15 min", "#F59E0B")

    st.markdown("""
    <div class="consolidated-box">
        <h2>VISÃO CONSOLIDADA</h2>
        <p>Selecione uma área específica no menu superior para acessar os detalhamentos e gráficos intraday.</p>
    </div>
    """, unsafe_allow_html=True)


# ==========================================
# ROTEAMENTO 2: MÓDULO SELIC (FOTOS 2 A 8)
# ==========================================
elif "SELIC" in menu_lateral:
    # Barra de Exportação CSV / PDF
    _, col_exp1, col_exp2 = st.columns([8.2, 0.9, 0.9])
    col_exp1.download_button(
        "⬇ Exportar CSV",
        data=df_pend.to_csv(index=False).encode("utf-8"),
        file_name="selic_operacoes.csv",
        mime="text/csv",
        use_container_width=True
    )
    col_exp2.button("📄 Gerar PDF", use_container_width=True)

    # Sub-abas Horizontais da SELIC
    aba_selic = st.radio(
        "Abas SELIC",
        options=[
            "Volume de Operações",
            "Financeiro por Horário",
            "Top Gestores",
            "Top Corretoras",
            "Leadtime (SLA)",
            "Operações Canceladas",
            "Natureza ⚡",
            "Heatmap ⚡",
            "Qualidade ⚡",
            "Previsão ARIMA ⚡",
            "Ranking Operacional ⚡"
        ],
        index=0,
        horizontal=True,
        label_visibility="collapsed"
    )

    # ----------------------------------------------------
    # VISÃO A: VOLUME DE OPERAÇÕES (FOTOS 2, 3 e 4)
    # ----------------------------------------------------
    if aba_selic == "Volume de Operações":
        # Bloco 1: Sem Termo
        st.markdown('<div class="sec-title">Volume de Operações Recepcionadas</div>', unsafe_allow_html=True)
        v1, v2, v3, v4 = st.columns(4)
        with v1:
            render_kpi_card("PICO DE LIQUIDAÇÃO (VOL) - SEM TERMO", "09:00", "~2237 ops/dia na média", "#10B981")
        with v2:
            render_kpi_card("HORÁRIO MAIS VOLÁTIL - SEM TERMO", "17:00", "Alta dispersão (p25-p75)", "#10B981")
        with v3:
            render_kpi_card("MÉDIA DIÁRIA (OPERAÇÕES) - SEM TERMO", "7.145", "Ticket: R$ 142.847.079,08", "#F59E0B")
        with v4:
            render_kpi_card("TOTAL NO PERÍODO - SEM TERMO", "92.886", "13 dias úteis", "#10B981")

        st.markdown("""
        <div class="chart-box-header">
            <span class="chart-box-title">Distribuição Intraday - Sem Termo</span>
            <span class="chart-tag">VOLUME PATTERN</span>
        </div>
        """, unsafe_allow_html=True)

        chk_cols = st.columns([1.1, 1.3, 1.1, 1.6, 5])
        st_p75 = chk_cols[0].checkbox("P75/P25", value=True, key="st_p75")
        st_rec = chk_cols[1].checkbox("Recepção (Início)", value=True, key="st_rec")
        st_fin = chk_cols[2].checkbox("Finalização", value=True, key="st_fin")
        st_cmp = chk_cols[3].checkbox("Período Comparação", value=True, key="st_cmp")

        fig_vol_st = go.Figure()
        if st_p75:
            fig_vol_st.add_trace(go.Scatter(
                x=df_intraday["hora"], y=[v * 1.12 for v in df_intraday["rec_st_base"]],
                mode="lines", line=dict(width=0), name="P75", showlegend=True
            ))
            fig_vol_st.add_trace(go.Scatter(
                x=df_intraday["hora"], y=[v * 0.88 for v in df_intraday["rec_st_base"]],
                mode="lines", line=dict(width=0), fill="tonexty",
                fillcolor="rgba(56, 189, 248, 0.14)", name="P25", showlegend=True
            ))
        if st_rec:
            fig_vol_st.add_trace(go.Scatter(
                x=df_intraday["hora"], y=df_intraday["rec_st_base"], mode="lines+markers",
                name="Recepção (Início) - Período Base",
                line=dict(color="#22D3EE", width=2.8, shape="spline")
            ))
        if st_fin:
            fig_vol_st.add_trace(go.Scatter(
                x=df_intraday["hora"], y=df_intraday["fin_st_base"], mode="lines+markers",
                name="Finalização - Período Base",
                line=dict(color="#10B981", width=2.8, shape="spline")
            ))
        if st_cmp and st_rec:
            fig_vol_st.add_trace(go.Scatter(
                x=df_intraday["hora"], y=df_intraday["rec_st_comp"], mode="lines+markers",
                name="Recepção (Início) - Comparação",
                line=dict(color="#FB7185", width=2, dash="dot", shape="spline")
            ))
        if st_cmp and st_fin:
            fig_vol_st.add_trace(go.Scatter(
                x=df_intraday["hora"], y=df_intraday["fin_st_comp"], mode="lines+markers",
                name="Finalização - Comparação",
                line=dict(color="#FBBF24", width=2, dash="dot", shape="spline")
            ))
        st.plotly_chart(style_plotly(fig_vol_st, height=310), use_container_width=True)

        # Bloco 2: Termo
        st.markdown('<div class="sec-title">Volume de Operações Recepcionadas — Termo</div>', unsafe_allow_html=True)
        t1, t2, t3, t4 = st.columns(4)
        with t1:
            render_kpi_card("PICO DE LIQUIDAÇÃO (VOL) - TERMO", "18:00", "~550 ops/dia na média", "#10B981")
        with t2:
            render_kpi_card("HORÁRIO MAIS VOLÁTIL - TERMO", "17:00", "Alta dispersão (p25-p75)", "#10B981")
        with t3:
            render_kpi_card("MÉDIA DIÁRIA (OPERAÇÕES) - TERMO", "1.308", "Ticket: R$ 11.103.089,32", "#F59E0B")
        with t4:
            render_kpi_card("TOTAL NO PERÍODO - TERMO", "17.002", "13 dias úteis", "#10B981")

        st.markdown("""
        <div class="chart-box-header">
            <span class="chart-box-title">Distribuição Intraday - Termo</span>
            <span class="chart-tag">VOLUME PATTERN</span>
        </div>
        """, unsafe_allow_html=True)

        t_cols = st.columns([1.1, 1.3, 1.1, 1.6, 5])
        t_p75 = t_cols[0].checkbox("P75/P25", value=True, key="t_p75")
        t_rec = t_cols[1].checkbox("Recepção (Início)", value=True, key="t_rec")
        t_fin = t_cols[2].checkbox("Finalização", value=True, key="t_fin")
        t_cmp = t_cols[3].checkbox("Período Comparação", value=True, key="t_cmp")

        fig_vol_t = go.Figure()
        if t_p75:
            fig_vol_t.add_trace(go.Scatter(
                x=df_intraday["hora"], y=[v * 1.15 for v in df_intraday["fin_t_base"]],
                mode="lines", line=dict(width=0), name="P75", showlegend=True
            ))
            fig_vol_t.add_trace(go.Scatter(
                x=df_intraday["hora"], y=[v * 0.85 for v in df_intraday["fin_t_base"]],
                mode="lines", line=dict(width=0), fill="tonexty",
                fillcolor="rgba(56, 189, 248, 0.20)", name="P25", showlegend=True
            ))
        if t_rec:
            fig_vol_t.add_trace(go.Scatter(
                x=df_intraday["hora"], y=df_intraday["rec_t_base"], mode="lines+markers",
                name="Recepção (Início) - Período Base (Termo)",
                line=dict(color="#38BDF8", width=2.6, shape="spline")
            ))
        if t_fin:
            fig_vol_t.add_trace(go.Scatter(
                x=df_intraday["hora"], y=df_intraday["fin_t_base"], mode="lines+markers",
                name="Finalização - Período Base (Termo)",
                line=dict(color="#60A5FA", width=2.6, shape="spline")
            ))
        if t_cmp and t_rec:
            fig_vol_t.add_trace(go.Scatter(
                x=df_intraday["hora"], y=df_intraday["rec_t_comp"], mode="lines+markers",
                name="Recepção (Início) - Comparação (Termo)",
                line=dict(color="#FBBF24", width=2, dash="dot", shape="spline")
            ))
        if t_cmp and t_fin:
            fig_vol_t.add_trace(go.Scatter(
                x=df_intraday["hora"], y=df_intraday["fin_t_comp"], mode="lines+markers",
                name="Finalização - Comparação (Termo)",
                line=dict(color="#FB7185", width=2, dash="dot", shape="spline")
            ))
        st.plotly_chart(style_plotly(fig_vol_t, height=300), use_container_width=True)

        # Bloco 3: Visão Consolidada de Recepção e Liquidação (Foto 4)
        st.markdown('<div class="sec-title">Visão Consolidada de Recepção e Liquidação</div>', unsafe_allow_html=True)
        col_rk1, col_rk2 = st.columns(2)

        top10_gestores_vol = [
            ("MIDDLE_ASSET", 35420, "35.420"),
            ("B3F", 29307, "29.307"),
            ("KINEA", 11382, "11.382"),
            ("KAPITINT", 6866, "6.866"),
            ("GRIFFO", 5044, "5.044"),
            ("ACECAPITAL", 2587, "2.587"),
            ("VINLAND", 1760, "1.760"),
            ("B43", 1644, "1.644"),
            ("TEMPLETON", 1628, "1.628"),
            ("FAPES", 1002, "1.002"),
        ]
        top10_pos16 = [
            ("MIDDLE_ASSET", 5029, "5.029"),
            ("KAPITINT", 4573, "4.573"),
            ("LEGACY", 403, "403"),
            ("IBIUNA", 76, "76"),
            ("PORTOINVEST", 62, "62"),
            ("KINEA", 58, "58"),
            ("GRIFFO", 53, "53"),
            ("GENOA", 40, "40"),
            ("SPXEQUITIES", 20, "20"),
            ("VINLAND", 17, "17"),
        ]

        with col_rk1:
            render_horizontal_ranking("Top 10 Gestores", "VOLUME", top10_gestores_vol, bar_style="cyan")
        with col_rk2:
            render_horizontal_ranking(
                "Gestores que mais boletam após 16h",
                "A Termo | Sem Termo",
                top10_pos16,
                bar_style="cyan",
                subtitle="10.373 operações na visão selecionada"
            )

        # Bloco 4: Tabela de Pendências
        render_pendencias_table(df_pend)

    # ----------------------------------------------------
    # VISÃO B: LEADTIME (SLA) (FOTOS 5, 6, 7 e 8)
    # ----------------------------------------------------
    elif aba_selic == "Leadtime (SLA)":
        # Filtro de Modalidade da Operação (Foto 5)
        with st.container(border=True):
            m1, m2, m3 = st.columns([3.5, 1.2, 4])
            m1.multiselect(
                "MODALIDADE DA OPERAÇÃO (FILTRO LEADTIME)",
                options=["Antecipação de compromissada", "Caução", "Compromissada", "Definitiva"],
                default=["Antecipação de compromissada", "Caução", "Compromissada"]
            )
            with m2:
                st.write("")
                b_sel1, b_sel2 = st.columns(2)
                b_sel1.button("✓ Selecionar Todas", use_container_width=True)
                b_sel2.button("✕ Limpar Seleção", use_container_width=True)

        # 1. Leadtime Total (Fotos 5 e 6)
        st.markdown('<div class="sec-title">Leadtime Total</div>', unsafe_allow_html=True)
        lt1, lt2, lt3, lt4 = st.columns(4)
        with lt1:
            render_kpi_card("LEADTIME MÉDIO TOTAL", "23.1 min", "Tempo de Processamento", "#10B981")
        with lt2:
            render_kpi_card("HORÁRIO MAIS CRÍTICO (GARGALO)", "08:00", "110.1 min na média", "#F59E0B")
        with lt3:
            render_kpi_card("SLA TOTAL (< 15 MIN)", "68%", "Aderência ao Acordo", "#10B981")
        with lt4:
            render_kpi_card("TOTAL DE OPERAÇÕES", "109.888", "Operações processadas", "#10B981")

        st.markdown("""
        <div class="chart-box-header">
            <span class="chart-box-title">Leadtime Total por Horário</span>
            <span class="chart-tag">SLA MONITOR</span>
        </div>
        """, unsafe_allow_html=True)

        fig_lt_tot = go.Figure()
        fig_lt_tot.add_trace(go.Scatter(
            x=df_intraday["hora"], y=df_intraday["lt_tot_base"], mode="lines+markers",
            name="Leadtime Total - Período Base (min)",
            line=dict(color="#FDA4AF", width=2.8, shape="spline")
        ))
        fig_lt_tot.add_trace(go.Scatter(
            x=df_intraday["hora"], y=df_intraday["lt_tot_comp"], mode="lines+markers",
            name="Leadtime Total - Período Comparação (min)",
            line=dict(color="#2DD4BF", width=2, dash="dot", shape="spline")
        ))
        st.plotly_chart(style_plotly(fig_lt_tot, height=280), use_container_width=True)

        # 2. Leadtime Itaú (Foto 6)
        st.markdown('<div class="sec-title">Leadtime Itaú</div>', unsafe_allow_html=True)
        li1, li2, li3, li4 = st.columns(4)
        with li1:
            render_kpi_card("LEADTIME MÉDIO ITAÚ", "7.0 min", "Processamento Interno", "#10B981")
        with li2:
            render_kpi_card("HORÁRIO MAIS CRÍTICO (ITAÚ)", "08:00", "87.0 min na média", "#F59E0B")
        with li3:
            render_kpi_card("SLA ITAÚ (< 10 MIN)", "88%", "Eficiência Interna", "#10B981")
        with li4:
            render_kpi_card("% DO LEADTIME TOTAL", "30%", "Responsabilidade", "#F59E0B")

        st.markdown("""
        <div class="chart-box-header">
            <span class="chart-box-title">Leadtime Itaú por Horário</span>
            <span class="chart-tag">INTERNAL PERFORMANCE</span>
        </div>
        """, unsafe_allow_html=True)

        fig_lt_itau = go.Figure()
        fig_lt_itau.add_trace(go.Scatter(
            x=df_intraday["hora"], y=df_intraday["lt_itau_base"], mode="lines+markers",
            name="Leadtime Itaú - Período Base (min)",
            line=dict(color="#34D399", width=2.8, shape="spline")
        ))
        fig_lt_itau.add_trace(go.Scatter(
            x=df_intraday["hora"], y=df_intraday["lt_itau_comp"], mode="lines+markers",
            name="Leadtime Itaú - Período Comparação (min)",
            line=dict(color="#2DD4BF", width=2, dash="dot", shape="spline")
        ))
        st.plotly_chart(style_plotly(fig_lt_itau, height=280), use_container_width=True)

        # 3. Leadtime Contraparte (Foto 8)
        st.markdown('<div class="sec-title">Leadtime Contraparte</div>', unsafe_allow_html=True)
        lc1, lc2, lc3, lc4 = st.columns(4)
        with lc1:
            render_kpi_card("LEADTIME MÉDIO CONTRAPARTE", "16.2 min", "Processamento Externo", "#10B981")
        with lc2:
            render_kpi_card("HORÁRIO MAIS CRÍTICO (CONTRAPARTE)", "10:00", "63.9 min na média", "#F59E0B")
        with lc3:
            render_kpi_card("SLA CONTRAPARTE (< 10 MIN)", "71%", "Eficiência Externa", "#10B981")
        with lc4:
            render_kpi_card("% DO LEADTIME TOTAL", "70%", "Dependência Externa", "#F59E0B")

        st.markdown("""
        <div class="chart-box-header">
            <span class="chart-box-title">Leadtime Contraparte por Horário</span>
            <span class="chart-tag">EXTERNAL PERFORMANCE</span>
        </div>
        """, unsafe_allow_html=True)

        fig_lt_cp = go.Figure()
        fig_lt_cp.add_trace(go.Scatter(
            x=df_intraday["hora"], y=df_intraday["lt_cp_base"], mode="lines+markers",
            name="Leadtime Contraparte - Período Base (min)",
            line=dict(color="#E2E8F0", width=2.8, shape="spline")
        ))
        fig_lt_cp.add_trace(go.Scatter(
            x=df_intraday["hora"], y=df_intraday["lt_cp_comp"], mode="lines+markers",
            name="Leadtime Contraparte - Período Comparação (min)",
            line=dict(color="#2DD4BF", width=2, dash="dot", shape="spline")
        ))
        st.plotly_chart(style_plotly(fig_lt_cp, height=280), use_container_width=True)

        # 4. Origem e Impacto dos Atrasos (Fotos 7 e 8)
        st.markdown('<div class="sec-title">Origem e Impacto dos Atrasos</div>', unsafe_allow_html=True)
        with st.container(border=True):
            st.selectbox("CONTRAPARTE / CORRETORA", ["Todas as contrapartes", "JPMorgan", "BGC", "UBS", "DEUTSCHE"])

        col_at1, col_at2 = st.columns(2)
        top10_gestores_atraso = [
            ("PROFI", 515.0, "515.0 min"),
            ("JP_NEW_YORK", 452.4, "452.4 min"),
            ("BANKNYC", 442.0, "442.0 min"),
            ("ITAUEUROPA", 271.4, "271.4 min"),
            ("ROBECPRO", 264.4, "264.4 min"),
            ("PICTET", 228.0, "228.0 min"),
            ("REBUS", 191.4, "191.4 min"),
            ("SUNW", 190.8, "190.8 min"),
            ("CREDAGRICOLE", 167.8, "167.8 min"),
            ("BANCOSUISSE", 152.7, "152.7 min"),
        ]
        top10_corretoras_atraso = [
            ("JPMorgan", 603.0, "603.0 min"),
            ("BGC", 449.0, "449.0 min"),
            ("UBS", 331.2, "331.2 min"),
            ("DEUTSCHE", 227.2, "227.2 min"),
            ("GOLDMAN", 201.8, "201.8 min"),
            ("BANCOBB", 191.4, "191.4 min"),
            ("MERRIL", 187.7, "187.7 min"),
            ("CALYON", 167.5, "167.5 min"),
            ("HSBC", 159.4, "159.4 min"),
            ("CITIBANK", 157.1, "157.1 min"),
        ]

        with col_at1:
            render_horizontal_ranking("Top 10 Gestores Impactados", "CONTRAPARTE X GESTOR", top10_gestores_atraso, bar_style="amber")
        with col_at2:
            render_horizontal_ranking("Top 10 Corretoras que Mais Atrasam", "LEADTIME MÉDIO", top10_corretoras_atraso, bar_style="amber")

        # 5. Tabela de Pendências
        render_pendencias_table(df_pend)

    else:
        st.info(f"Aba **{aba_selic}** pronta para receber a implementação na próxima etapa.")

else:
    st.info(f"Módulo **{menu_lateral}** selecionado. Clique em **◆ Home** ou **● SELIC** para visualizar as telas implementadas.")
