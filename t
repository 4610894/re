============
st.markdown('<div class="top-tag">INSTITUTIONAL OPERATIONS • AI POWERED</div>', unsafe_allow_html=True)
st.markdown('<h1 class="page-title">Saúde da Operação</h1>', unsafe_allow_html=True)
st.markdown('<div class="page-subtitle">Liquidação, risco, eficiência e comportamento operacional em visão executiva.</div>', unsafe_allow_html=True)

if "Home" in menu_lateral:
    bc_html = '<div class="breadcrumb-box"><span>Home</span> <span class="bc-pill">Dashboard</span></div>'
    status_html = '<div class="status-pills"><div class="status-badge"><span class="dot-green"></span> Dados consolidados</div></div>'
else:
    bc_html = '<div class="breadcrumb-box"><span>Home</span> <span class="bc-pill">SELIC</span></div>'
    status_html = '<div class="status-pills"><div class="status-badge"><span class="dot-green"></span> Dados consolidados</div><div class="status-badge"><span class="dot-green"></span> Sistema online</div></div>'

st.markdown(f'<div class="header-bar">{bc_html}{status_html}</div>', unsafe_allow_html=True)

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
# ROTEAMENTO 1: PÁGINA INICIAL
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
# ROTEAMENTO 2: MÓDULO SELIC
# ==========================================
elif "SELIC" in menu_lateral:
    _, col_exp1, col_exp2 = st.columns([8.2, 0.9, 0.9])
    col_exp1.download_button(
        "⬇ Exportar CSV",
        data=df_pend.to_csv(index=False).encode("utf-8"),
        file_name="selic_operacoes.csv",
        mime="text/csv",
        use_container_width=True
    )
    col_exp2.button("📄 Gerar PDF", use_container_width=True)

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

    if aba_selic == "Volume de Operações":
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
        ))
        st.plotly_chart(style_plotly(fig_vol_t, height=300), use_container_width=True)

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

        render_pendencias_table(df_pend)

    elif aba_selic == "Leadtime (SLA)":
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

        render_pendencias_table(df_pend)

    else:
        st.info(f"Aba **{aba_selic}** pronta para receber a implementação na próxima etapa.")

else:
    st.info(f"Módulo **{menu_lateral}** s










import pandas as pd

# 1. Configurações
ARQUIVO_ENTRADA = "amostras_setembro.csv"
ARQUIVO_SAIDA = "nova_base_sintetica.csv"
COLUNA_DATA = "data"  # Altere para o nome real da coluna de data no seu CSV

# Vetor de datas desejadas (pode ser lista de strings, datetime ou pd.date_range)
datas_alvo = [
    "2026-09-26",
    "2026-09-27",
    "2026-09-28",
    "2026-09-29",
    "2026-09-30",
]

# 2. Carrega a base original
df = pd.read_csv(ARQUIVO_ENTRADA)
df[COLUNA_DATA] = pd.to_datetime(df[COLUNA_DATA])

# 3. Calcula a média de amostras por dia na base original
contagem_por_dia = df.groupby(df[COLUNA_DATA].dt.normalize()).size()
media_por_dia = round(contagem_por_dia.mean())

print(f"Média de amostras por dia na base original: {contagem_por_dia.mean():.2f}")
print(f"Quantidade de amostras geradas por dia na nova base: {media_por_dia}")

# 4. Gera as novas amostras para cada data do vetor
novas_partes = []
for i, data in enumerate(datas_alvo):
    # Sorteia linhas reais com reposição para manter a mesma estrutura e colunas
    amostra_dia = df.sample(n=media_por_dia, replace=True, random_state=42 + i).copy()
    amostra_dia[COLUNA_DATA] = pd.to_datetime(data)
    novas_partes.append(amostra_dia)

# 5. Consolida e salva a nova base mantendo a mesma ordem/estrutura de colunas
df_novo = pd.concat(novas_partes, ignore_index=True)[df.columns]
df_novo.to_csv(ARQUIVO_SAIDA, index=False)

print(f"Arquivo '{ARQUIVO_SAIDA}' gerado com {len(df_novo)} linhas.")

