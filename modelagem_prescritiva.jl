### A Pluto.jl notebook ###
# v0.12.16

using Markdown
using InteractiveUtils

# ╔═╡ a2f3236a-39a1-11eb-14b0-1999fed9a384
using JuMP, GLPK, Cbc

# ╔═╡ 67263796-39a1-11eb-32e5-59ccc917e6b0
md"
# Modelagem Prescritiva

Curso ministrado pelo prof. **Claudio Lucio** na **A3Data** em 08-12-2020.

# Problema da fábrica de automóveis

**Seucarro Inc.** deve produzir 1000 automóveis Beta. A empresa tem 4 fábricas. Devido a diferenças na mão de obra e avanços tecnológicos, as plantas diferem no **custo de produção unitário** de cada carro.

Elas também utilizam diferentes quantidades de **matéria-prima** e **mão de obra**. O custo de operação, o tempo necessário de mão de obra e o custo de matéria prima para produzir uma unidade de cada carro em cada uma das fábricas estão evidenciados na tabela a seguir.

| Fábrica | Custo unitário em R$1.000,00 | Mão de obra (horas de fabricação) | Matéria-prima (unidades de material) |
|---------|------------------------------|-----------------------------------|--------------------------------------|
| 1       | 15                           | 2                                 | 3                                    |
| 2       | 10                           | 3                                 | 4                                    |
| 3       | 9                            | 4                                 | 5                                    |
| 4       | 7                            | 5                                 | 6                                    |

#### Pontos

- Existem 3200 horas de mão de obra no total;
- Existem 4000 unidades de material que podem ser alocados às quatro fábricas;
- Um acordo trabalhista assinado requer que pelo menos 250 carros sejam produzidos na fábrica 3.

#### Decisão 

Como produzir os 1000 carros com o menor custo?
"

# ╔═╡ 9f851ea8-39a2-11eb-1db2-85f866039fca
begin
	#Número de fábricas
	num_fabricas = 4

	#Total de carros a serem produzidos
	total_carros = 1000

	#Custo de produção por carro em cada fábrica
	Custo_unitario = [15 ,10, 9, 7 ]

	#Horas de mão de obra necessárias por carro em cada fábrica
	Horas_mao_obra = [2 ,3, 4, 5 ]

	#Materia prima necessária por carro em cada fábrica
	Materia_prima = [3 ,4, 5, 6 ]
end

# ╔═╡ b447b204-39ae-11eb-38ca-f7f607cfc064
md"#### Criando o modelo"

# ╔═╡ b8ece698-39a5-11eb-08cf-83dbe955ee14
modelo_fabrica = Model(GLPK.Optimizer)

# ╔═╡ 0dfebf1a-39a3-11eb-21d3-3bcadfa0634b
@variable(
	modelo_fabrica, 
	0 <= fabrica[1:num_fabricas] <= total_carros, 
	integer=true
)

# ╔═╡ a81fab50-39a7-11eb-2783-01d45eb55fdf
@constraints(modelo_fabrica, begin
	fabrica[3] >= 250
	sum([Horas_mao_obra[i] * fabrica[i] for i in 1:num_fabricas])  <= 3200
	sum([Materia_prima[i] * fabrica[i] for i in 1:num_fabricas]) <= 4000
	sum([fabrica[i] for i in 1:num_fabricas]) == total_carros
end)

# ╔═╡ 55f943da-39a8-11eb-31bc-0fb33d27b893
@objective(modelo_fabrica, Min, 
	sum([Custo_unitario[i] * fabrica[i] for i in 1:num_fabricas])
)

# ╔═╡ c5b19870-39ae-11eb-3bb2-81f4401b7b05
md"#### Executando o modelo"

# ╔═╡ 757b9eec-39a8-11eb-1f61-a1dda89f7707
optimize!(modelo_fabrica)

# ╔═╡ cc2d2866-39ae-11eb-056d-252e1372c0ff
md"#### Avaliando os resultados"

# ╔═╡ d323c636-39a9-11eb-1a7a-b1f548721c2f
objective_value(modelo_fabrica)

# ╔═╡ f26d1524-39a9-11eb-33c9-e559eb1205fc
value.(fabrica)

# ╔═╡ 05805e5c-39aa-11eb-38d6-c3f5339f1e54
md"
# Case 2 - HostM - Produtos Digitais

A **HotsM** é uma empresa de produtos digitais e com uma gestão financeira muito profissional. Para os próximos 3 anos,m estão previstos um lucro líquido de 200, 250 e 150 milhões de reais.

Eles possuem vários projetos de investimento (participações em outras empresas) e precisam definir quanto e quais projetos tem chance de trazer maior retorno. Para isto, foi calculado o VPL (Valor presente líquido) de cada projeto, veja a tabela com os os dados levantados.

| Projeto de Investimento | Investimentos Ano 1 | Investimentos Ano 2 | Investimentos Ano 3 | VPL dos investimentos |
|-------------------------|---------------------|---------------------|---------------------|---------------------|
| Projeto 1               | 12                  | 34                  | 12                  | 20                  |
| Projeto 2               | 54                  | 94                  | 67                  | 15                  |
| Projeto 3               | 65                  | 28                  | 49                  | 34                  |
| Projeto 4               | 38                  | 0                   | 8                   | 17                  |
| Projeto 5               | 52                  | 21                  | 42                  | 56                  |
| Projeto 6               | 98                  | 73                  | 25                  | 76                  |
| Projeto 7               | 15                  | 48                  | 53                  | 29                  |

O critério é que caso ela opte por algum projeto eles devem manter a proporcionalidade de aplicações de durante todos os anos (para o ano 1, ano 2 e ano 3 ele deve manter 10% de alocação de investimento em todos os anos.

#### Decisão

Qual percentual de cada projeto devo investir para obter o maior VPL?
"

# ╔═╡ 37fae150-39ac-11eb-24ab-15d68c6059aa
begin
	# Número de projetos
	num_projetos = 7
	
	# Valor total dos projetos por ano
	cronograma_desembolso = [12 34 12;
						  	 54 94 67;
						  	 65 28 49;
						  	 38  0  8;
						     52 21 42;
						   	 98 73 25;
						     15 48 53]
	
	# VPL dos projetos
	vpl_projeto = [20, 15, 34, 17, 56, 76, 29]
	
	# Valor máximo de desembolso por ano
	previsto_desembolso = [200, 250, 150]
end

# ╔═╡ df204e14-39ae-11eb-2bc6-03dfba88efc2
md"#### Criando o modelo"

# ╔═╡ a7866490-39ac-11eb-2aec-69cbe11f234e
modelo_projetos_inv = Model(GLPK.Optimizer)

# ╔═╡ ac00e038-39ac-11eb-331d-4553089ba322
@variable(modelo_projetos_inv, 
	0 <= projeto[1:num_projetos] <= 1)

# ╔═╡ fb8424ec-39ac-11eb-37f0-b3b6221bd896
@objective(modelo_projetos_inv,
	Max,
	sum([vpl_projeto[i] * projeto[i] for i in 1:num_projetos])
)

# ╔═╡ 31551022-39ad-11eb-2373-fdbd115be751
@constraints(modelo_projetos_inv, begin
	sum([cronograma_desembolso[i,1] * projeto[i] for i in 1:num_projetos]) <= previsto_desembolso[1]
	sum([cronograma_desembolso[i,2] * projeto[i] for i in 1:num_projetos]) <= previsto_desembolso[2]
	sum([cronograma_desembolso[i,3] * projeto[i] for i in 1:num_projetos]) <= previsto_desembolso[3]
end)

# ╔═╡ e9505a14-39ae-11eb-3c0b-9938426acc06
md"#### Executando o modelo"

# ╔═╡ d4b8a260-39ad-11eb-3822-1b8039ae179d
optimize!(modelo_projetos_inv)

# ╔═╡ ef629a84-39ae-11eb-045c-cd3d40f7e09f
md"#### Avaliando os resultados"

# ╔═╡ dcc819cc-39ad-11eb-1d15-efca6e22b87a
round(objective_value(modelo_projetos_inv), digits=2)

# ╔═╡ 2e2cc1e6-39ae-11eb-0f62-8f74234c74d8
value.(projeto)

# ╔═╡ bc82cf92-39ab-11eb-2a08-a18393e9bfbd
md"

# Case 3 - 757 Mobility Startup

Suponha que você foi contratado como cientista de dados da **757 Mobility Startup** - serviço de assinatura de mobilidade e locomoção.

O primeiro problema para resolver é: dado uma região geográfica (um bairro, por exemplo), você deve calcular em tempo real:

- Número de chamadas de clientes no aplicativo
- Número de motoristas com latitude e longitude dentro da região
- Velocidade média de deslocamento no horário dentro da região
- Atribuir as chamadas para os motoristas de forma que o nível de serviço seja atendido para todos os clientes
- Resolver o problema para reduzir o tempo de espera de todos os envolvidos

#### Organizando os dados
"

# ╔═╡ cf987b18-39b0-11eb-0349-d5cfe4b1fdc9
tempo_previsto = rand.([1:200], 30, 20)[1]

# ╔═╡ 169ca1d8-39b1-11eb-00e3-e56ee1b097bc
(numero_clientes, numero_motoristas) = size(tempo_previsto)

# ╔═╡ ed7e7300-39b1-11eb-2fce-dff9da1e72c7
md"#### Criando o modelo"

# ╔═╡ fdde9d08-39b1-11eb-24a8-092b67c78edc
begin
	modelo_atendimento = Model(GLPK.Optimizer)
	#set_optimizer_attribute(modelo_atendimento, "logLevel", 1)
end

# ╔═╡ 65bc979a-39b2-11eb-02ea-49369b13bdfc
@variable(modelo_atendimento,
	atendimento[1:numero_clientes, 1:numero_motoristas],
	binary = true
)

# ╔═╡ a528275a-39b5-11eb-2681-99de6f4cfb9f
@objective(
	modelo_atendimento,
	Min,
	sum([tempo_previsto[i,j] * atendimento[i,j] for i in 1:numero_clientes for j in 1:numero_motoristas])
)

# ╔═╡ e92bf0a0-39b5-11eb-01d4-65ee208fc816
# Cada cliente deve ser atendido por apenas 1 motorista
@constraint(modelo_atendimento, 
		[k = 1:numero_clientes], 
		sum(atendimento[k,:]) == 1)


# ╔═╡ 4bdd42c0-39d0-11eb-291a-dbe3bbf08bd0
# Cada motorista deve atender no máximo 1 pessoa naquele instante de tempo
@constraint(modelo_atendimento, 
		[j = 1:numero_motoristas], 
		sum(atendimento[:,j]) == 1)


# ╔═╡ 2cad59ca-39b8-11eb-2f27-5342c5b170f4
md"#### Executando o modelo"

# ╔═╡ 34724ca8-39b8-11eb-22b6-c5fe3ede175c
optimize!(modelo_atendimento)

# ╔═╡ 3edd0e2e-39b8-11eb-16b1-370d82b3905c
md"#### Avaliando o modelo"

# ╔═╡ 18222466-39ce-11eb-2e35-2d1ec62c8d72
tempo_total = objective_value(modelo_atendimento)

# ╔═╡ 4842653e-39b8-11eb-3371-4553f7155bda
md"Tempo total: $tempo_total"

# ╔═╡ dddc678e-39ba-11eb-2169-c1687dcde903
md"

Este problema, da forma como está, é infactível. Será necessário investigar mais...

"

# ╔═╡ f3eb9a68-39ba-11eb-156e-df23209f534b
md"
# Desafio

Você terminou de implantar o algoritmo de recomendação de produtos para os perfis de clientes na **W2B - E-Commerce**. Você tem certeza da qualidade das recomendações. O algoritmo está com um bom grau de acurácia e precisão. mas você foi chamado para uma reunião com o gerente de estoque do E-Commerce:

- Problema o algoritmo não leva em consideração os níveis de estoque, na hora de fazer a recomendação.
- O bot de atendimento já registrou muitos clientes dizendo que receberam a recomendação mas \"nunca tem o produto no estoque\"

Sua missão agora é resolver este problema:

- Manter a acurácia das recomendações: o cross selling está funcionando;
- Resolver o problema da insatisfação dos clientes e recomendar o que tem estoque para uma faixa menor de clientes que são potenciais para compra do produto.

Na tabela há uma saída do algoritmo de recomendação para um instante no tempo.

| Cliente   | Produto 1 (score) | Produto 2 (score) | Produto 3 (score) | Produto 4 (score) |
|-----------|-------------------|-------------------|-------------------|-------------------|
| Cliente 1 | 11                | 4                 | 3                 | 9                 |
| Cliente 2 | 3                 | 7                 | 2                 | 3                 |
| Cliente 3 | 4                 | 9                 | 6                 | 5                 |
| Cliente 4 | 5                 | 4                 | 7                 | 7                 |
| Cliente N | ...               | ...               | ...               | ...               |

- Para cada produto você também terá a quantidade em estoque, e este valor significa o número de clientes máximo apra o qual você deve recomendar o produto
- Você deve manter a qualidade do seu algoritmo, mas a sua recomendação agora deve respeitar o estoque, mas de forma que o score geral seja o máximo possível.

## Algoritmo de recomendação com restrição de estoque
"

# ╔═╡ 831b9ae4-39bb-11eb-2e43-b9582066d888
begin
	todos_escores = [13  5 10  7 11  1 12 5;
	                  8  7  1 11 11  0  0 1;
	                  4  6  9  8 11  6  7 11;
	                 13  5 11  1  7 10 11 5;
	                 11  9  5  1  6  3  1 3;
	                  9 11  8 14  7  5  6 1;
	                  9  2  5  4  9  0 10 1;
	                 14  2 13  3 10  6 11 10;
	                  6  0 14  5 11  5  1 0;
	                 10  5  0 14  5  9  6 10;       
	                 12  6 11  7  0 13  3 5;
	                 12  7  4  4 13 10 12 14;
	                  9  5  7  1  8  5  9 13;
	                 11  9  5  6  2  1  1 2;
	                 10  1  0  3 13 12 14 7;
	                  3  4  4  0  5  8  1 11;
	                  0 12  2 14 10 14  7 5;
	                 10 12 14  4  4  1  9 11;     
	                  2  6  1 10 11  8  4 4;
	                 11 10 10  6  4  6  5 3]
	
	
	#Número de clientes e produtos no instante t
	(nclientes, nprodutos) = size(todos_escores)
	
	#Limites do estoque por produto
	Limites_estoque = [2, 1, 3, 0, 10, 4, 2, 4]
end

# ╔═╡ 9d1a9a5c-39bc-11eb-1dfd-5118b60f2807
md"Número de produtos: $nprodutos

Número de clientes: $nclientes"

# ╔═╡ 8e83bb84-39bc-11eb-1c17-294bbc19a85b
md"#### Criando o modelo"

# ╔═╡ 4b8c0946-39bc-11eb-1e27-3ba570aa36c8
begin
	modelo_rec = Model(GLPK.Optimizer)
	#set_optimizer_attribute(modelo_rec, "logLevel", 1)
end


# ╔═╡ 766fb598-39d2-11eb-2950-25d28034975f
# Variáveis de decisão
# Eu recomendo ou não recomendo o produto para o cliente?
@variable(
	modelo_rec, 
	recomendo[1:nclientes , 1:nprodutos],
	binary = true
)


# ╔═╡ 82523566-39d2-11eb-257f-9d4e1aba69d9
#score_ponderado = reshape([todos_escores[i,j] * Limites_estoque[j] for j in 1:nprodutos for i in 1:nclientes], nclientes, nprodutos)	
@objective(modelo_rec,
	Max,
	sum([todos_escores[i,j] * recomendo[i,j] for i in 1:nclientes for j in 1:nprodutos])
)


# ╔═╡ 39e0f328-39c1-11eb-27e9-f119ef807cf7
# Cada cliente recebe apenas 1 recomendação
@constraint(modelo_rec,
		[i = 1:nclientes], 
		sum(recomendo[i,:]) == 1
	)
	

# ╔═╡ 2f0397e6-39d3-11eb-204c-af04989c1be6
# Cada produto precisa ter pelo menos 1 item no estoque
@constraint(modelo_rec,
		[p = 1:nprodutos],
		sum([recomendo[i,p] * todos_escores[i,p] for i in 1:nclientes]) >= 1
	)


# ╔═╡ 36d36a1e-39d3-11eb-37cd-3305eeb57b77
# Cada produto só pode ser oferecido a quantidade de vezes que tem no estoque
	@constraint(modelo_rec,
		[pp = 1:nprodutos],
		sum([recomendo[i,pp] * todos_escores[i,pp] for i in 1:nclientes]) <= Limites_estoque[pp]
	)

# ╔═╡ 5e56d4be-39bc-11eb-1d92-4573b23d739f
md"#### Executando e avaliando o modelo"

# ╔═╡ d06ce7dc-39c8-11eb-1939-49af647af816
optimize!(modelo_rec)

# ╔═╡ 301cede2-39cb-11eb-1b84-918f2e8d5bf4
objective_value(modelo_rec)

# ╔═╡ 3c4f18e2-39cb-11eb-3876-df767d9d5860
value.(recomendo)

# ╔═╡ 26b714c0-39bd-11eb-3cd2-7365e0b0ab6d
md"
# Anotações finais

Quando devo aplicar análise prescritiva:

- Tarefas muito repetitivas
- Decisões PRECISAM ser tomadas num tempo muito curto
- Atividades passíveis de muitos erros
- Atividades laboriosas e tediosas
- Possuem um largo número de opções de escolha
- Impossível achar a melhor opção manualmente
- Envolver várias áreas da empresa
"

# ╔═╡ Cell order:
# ╟─67263796-39a1-11eb-32e5-59ccc917e6b0
# ╠═a2f3236a-39a1-11eb-14b0-1999fed9a384
# ╠═9f851ea8-39a2-11eb-1db2-85f866039fca
# ╟─b447b204-39ae-11eb-38ca-f7f607cfc064
# ╠═b8ece698-39a5-11eb-08cf-83dbe955ee14
# ╠═0dfebf1a-39a3-11eb-21d3-3bcadfa0634b
# ╠═a81fab50-39a7-11eb-2783-01d45eb55fdf
# ╠═55f943da-39a8-11eb-31bc-0fb33d27b893
# ╟─c5b19870-39ae-11eb-3bb2-81f4401b7b05
# ╠═757b9eec-39a8-11eb-1f61-a1dda89f7707
# ╟─cc2d2866-39ae-11eb-056d-252e1372c0ff
# ╠═d323c636-39a9-11eb-1a7a-b1f548721c2f
# ╠═f26d1524-39a9-11eb-33c9-e559eb1205fc
# ╟─05805e5c-39aa-11eb-38d6-c3f5339f1e54
# ╠═37fae150-39ac-11eb-24ab-15d68c6059aa
# ╟─df204e14-39ae-11eb-2bc6-03dfba88efc2
# ╠═a7866490-39ac-11eb-2aec-69cbe11f234e
# ╠═ac00e038-39ac-11eb-331d-4553089ba322
# ╠═fb8424ec-39ac-11eb-37f0-b3b6221bd896
# ╠═31551022-39ad-11eb-2373-fdbd115be751
# ╟─e9505a14-39ae-11eb-3c0b-9938426acc06
# ╠═d4b8a260-39ad-11eb-3822-1b8039ae179d
# ╟─ef629a84-39ae-11eb-045c-cd3d40f7e09f
# ╠═dcc819cc-39ad-11eb-1d15-efca6e22b87a
# ╠═2e2cc1e6-39ae-11eb-0f62-8f74234c74d8
# ╟─bc82cf92-39ab-11eb-2a08-a18393e9bfbd
# ╠═cf987b18-39b0-11eb-0349-d5cfe4b1fdc9
# ╠═169ca1d8-39b1-11eb-00e3-e56ee1b097bc
# ╟─ed7e7300-39b1-11eb-2fce-dff9da1e72c7
# ╠═fdde9d08-39b1-11eb-24a8-092b67c78edc
# ╠═65bc979a-39b2-11eb-02ea-49369b13bdfc
# ╠═a528275a-39b5-11eb-2681-99de6f4cfb9f
# ╠═e92bf0a0-39b5-11eb-01d4-65ee208fc816
# ╠═4bdd42c0-39d0-11eb-291a-dbe3bbf08bd0
# ╟─2cad59ca-39b8-11eb-2f27-5342c5b170f4
# ╠═34724ca8-39b8-11eb-22b6-c5fe3ede175c
# ╟─3edd0e2e-39b8-11eb-16b1-370d82b3905c
# ╠═18222466-39ce-11eb-2e35-2d1ec62c8d72
# ╠═4842653e-39b8-11eb-3371-4553f7155bda
# ╟─dddc678e-39ba-11eb-2169-c1687dcde903
# ╟─f3eb9a68-39ba-11eb-156e-df23209f534b
# ╠═831b9ae4-39bb-11eb-2e43-b9582066d888
# ╠═9d1a9a5c-39bc-11eb-1dfd-5118b60f2807
# ╟─8e83bb84-39bc-11eb-1c17-294bbc19a85b
# ╠═4b8c0946-39bc-11eb-1e27-3ba570aa36c8
# ╠═766fb598-39d2-11eb-2950-25d28034975f
# ╠═82523566-39d2-11eb-257f-9d4e1aba69d9
# ╠═39e0f328-39c1-11eb-27e9-f119ef807cf7
# ╠═2f0397e6-39d3-11eb-204c-af04989c1be6
# ╠═36d36a1e-39d3-11eb-37cd-3305eeb57b77
# ╟─5e56d4be-39bc-11eb-1d92-4573b23d739f
# ╠═d06ce7dc-39c8-11eb-1939-49af647af816
# ╠═301cede2-39cb-11eb-1b84-918f2e8d5bf4
# ╠═3c4f18e2-39cb-11eb-3876-df767d9d5860
# ╟─26b714c0-39bd-11eb-3cd2-7365e0b0ab6d
