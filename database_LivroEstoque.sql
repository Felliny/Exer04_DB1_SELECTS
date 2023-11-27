CREATE DATABASE ex9
GO
USE ex9
GO
CREATE TABLE editora (
codigo			INT				NOT NULL,
nome			VARCHAR(30)		NOT NULL,
site			VARCHAR(40)		NULL
PRIMARY KEY (codigo)
)
GO
CREATE TABLE autor (
codigo			INT				NOT NULL,
nome			VARCHAR(30)		NOT NULL,
biografia		VARCHAR(100)	NOT NULL
PRIMARY KEY (codigo)
)
GO
CREATE TABLE estoque (
codigo			INT				NOT NULL,
nome			VARCHAR(100)	NOT NULL	UNIQUE,
quantidade		INT				NOT NULL,
valor			DECIMAL(7,2)	NOT NULL	CHECK(valor > 0.00),
codEditora		INT				NOT NULL,
codAutor		INT				NOT NULL
PRIMARY KEY (codigo)
FOREIGN KEY (codEditora) REFERENCES editora (codigo),
FOREIGN KEY (codAutor) REFERENCES autor (codigo)
)
GO
CREATE TABLE compra (
codigo			INT				NOT NULL,
codEstoque		INT				NOT NULL,
qtdComprada		INT				NOT NULL,
valor			DECIMAL(7,2)	NOT NULL,
dataCompra		DATE			NOT NULL
PRIMARY KEY (codigo, codEstoque, dataCompra)
FOREIGN KEY (codEstoque) REFERENCES estoque (codigo)
)
GO
INSERT INTO editora VALUES
(1,'Pearson','www.pearson.com.br'),
(2,'Civilização Brasileira',NULL),
(3,'Makron Books','www.mbooks.com.br'),
(4,'LTC','www.ltceditora.com.br'),
(5,'Atual','www.atualeditora.com.br'),
(6,'Moderna','www.moderna.com.br')
GO
INSERT INTO autor VALUES
(101,'Andrew Tannenbaun','Desenvolvedor do Minix'),
(102,'Fernando Henrique Cardoso','Ex-Presidente do Brasil'),
(103,'Diva Marília Flemming','Professora adjunta da UFSC'),
(104,'David Halliday','Ph.D. da University of Pittsburgh'),
(105,'Alfredo Steinbruch','Professor de Matemática da UFRS e da PUCRS'),
(106,'Willian Roberto Cereja','Doutorado em Lingüística Aplicada e Estudos da Linguagem'),
(107,'William Stallings','Doutorado em Ciências da Computacão pelo MIT'),
(108,'Carlos Morimoto','Criador do Kurumin Linux')
GO
INSERT INTO estoque VALUES
(10001,'Sistemas Operacionais Modernos ',4,108.00,1,101),
(10002,'A Arte da Política',2,55.00,2,102),
(10003,'Calculo A',12,79.00,3,103),
(10004,'Fundamentos de Física I',26,68.00,4,104),
(10005,'Geometria Analítica',1,95.00,3,105),
(10006,'Gramática Reflexiva',10,49.00,5,106),
(10007,'Fundamentos de Física III',1,78.00,4,104),
(10008,'Calculo B',3,95.00,3,103)
GO
INSERT INTO compra VALUES
(15051,10003,2,158.00,'04/07/2021'),
(15051,10008,1,95.00,'04/07/2021'),
(15051,10004,1,68.00,'04/07/2021'),
(15051,10007,1,78.00,'04/07/2021'),
(15052,10006,1,49.00,'05/07/2021'),
(15052,10002,3,165.00,'05/07/2021'),
(15053,10001,1,108.00,'05/07/2021'),
(15054,10003,1,79.00,'06/08/2021'),
(15054,10008,1,95.00,'06/08/2021')

--1) Consultar nome, valor unitário, nome da editora e 
--nome do autor dos livros do estoque que foram vendidos. 
--Não podem haver repetições.

select es.nome,
	   es.valor,
	   edi.nome,
	   au.nome
from autor au, editora edi, estoque es
where au.codigo = es.codAutor
	and es.codEditora = edi.codigo

--2) Consultar nome do livro, quantidade comprada e 
--valor de compra da compra 15051	

select es.nome,
	   com.qtdComprada,
	   com.valor
from estoque es, compra com
where es.codigo = com.codEstoque
	and com.codigo = 15051 

-- 3) Consultar Nome do livro e 
-- site da editora dos livros da Makron books 
--(Caso o site tenha mais de 10 dígitos, remover o www.).

select es.nome,
	   SUBSTRING(edi.site, 5, 20) as site_editora
from estoque es, editora edi
where es.codEditora = edi.codigo
	and edi.nome like 'Makron%'

-- 4) Consultar nome do livro e Breve Biografia do David Halliday	

select es.nome,
	   au.biografia
from estoque es, autor au
where es.codAutor = au.codigo
	and au.nome like 'David Halli%'

-- 5) Consultar código de compra e quantidade comprada do 
--livro Sistemas Operacionais Modernos	

select com.codigo,
		com.qtdComprada
from compra com, estoque es
where com.codEstoque = es.codigo
	and es.nome like 'Sistemas Ope%'

-- 6) Consultar quais livros não foram vendidos

select es.nome,
		es.codigo
from estoque es left join compra com on es.codigo = com.codEstoque
where com.codEstoque is null

-- 7) Consultar quais livros foram vendidos e não estão cadastrados	

select com.codEstoque
from compra com left join estoque es on es.codigo = com.codEstoque
where es.codigo is null

-- 8) Consultar Nome e site da editora que não tem Livros no estoque 
-- (Caso o site tenha mais de 10 dígitos, remover o www.)	

select edi.nome,
		case when (len(edi.site) > 10)
		then
			SUBSTRING(edi.site, 5, 20)
		else
			edi.site
		end as site_editora
from editora edi left join estoque es on es.codEditora = edi.codigo
where es.codEditora is null

-- 9) Consultar Nome e biografia do autor que não tem Livros no estoque 
-- (Caso a biografia inicie com Doutorado, substituir por Ph.D.)	

select au.nome,
		au.biografia
from autor au left join estoque es on es.codAutor = au.codigo
where es.codAutor is null

-- 10) Consultar o nome do Autor, e o maior valor de Livro no estoque. 
-- Ordenar por valor descendente	

select au.nome,
		max(es.valor)
from autor au, estoque es
where au.codigo = es.codAutor
group by au.nome, es.valor
order by es.valor DESC

-- 11) Consultar o código da compra, o total de livros comprados 
-- e a soma dos valores gastos. Ordenar por Código da Compra ascendente.
	
select com.codigo,
		sum(com.qtdComprada) as quantidade_comprada,
		sum(com.valor) as valor_total
from compra com
group by com.codigo
order by com.codigo asc

-- 12) Consultar o nome da editora e a média de preços dos livros em estoque.
--Ordenar pela Média de Valores ascendente.


select edi.nome,
		SUBSTRING(cast(AVG(es.valor) as varchar), 1, 5) as media_valores
from editora edi, estoque es
where edi.codigo = es.codEditora
group by edi.nome
order by media_valores asc

-- 13) Consultar o nome do Livro, a quantidade em estoque o nome da editora, 
-- o site da editora (Caso o site tenha mais de 10 dígitos, remover o www.), 
-- criar uma coluna status onde:	
--	Caso tenha menos de 5 livros em estoque, escrever Produto em Ponto de Pedido
--	Caso tenha entre 5 e 10 livros em estoque, escrever Produto Acabando
--	Caso tenha mais de 10 livros em estoque, escrever Estoque Suficiente
--	A Ordenação deve ser por Quantidade ascendente

select es.nome, 
		es.quantidade,
		edi.nome,
		case when (len(edi.site) > 10)
		then
			SUBSTRING(edi.site, 5, 20)
		else
			edi.site
		end as site_editora,
		case when (es.quantidade < 5)
		then 
			'Produto em ponto de pedido'
		when (es.quantidade >= 5 and es.quantidade <= 10) then
			'Produto Acabando'
	    else
			'Estoque suficiente'
		end as status
from estoque es, editora edi
where es.codEditora = edi.codigo
order by es.quantidade asc

-- 14) Para montar um relatório, é necessário montar uma consulta com a 
-- seguinte saída: Código do Livro, Nome do Livro, Nome do Autor, Info 
-- Editora (Nome da Editora + Site) de todos os livros	
--	Só pode concatenar sites que não são nulos

select es.codigo,
		es.nome,
		au.nome,
		case when (edi.site is null)
		then
			edi.nome
		else
			edi.nome + '   ' + edi.site
		end as info_editora		
from estoque es, autor au, editora edi
where es.codAutor = au.codigo
	and es.codEditora = edi.codigo

-- 15) Consultar Codigo da compra, quantos dias da compra até hoje e 
-- quantos meses da compra até hoje

select com.codigo,
		DATEDIFF(day, com.dataCompra, GETDATE()) as dias_ate_hoje,
		DATEDIFF(MONTH, com.dataCompra, GETDATE()) as meses_ate_hoje
from compra com
group by com.codigo, com.dataCompra

-- 16) Consultar o código da compra e a soma dos valores gastos das compras 
-- que somam mais de 200.00	

select comp.codigo,
		sum(comp.valor) as valor_total
from compra comp
group by comp.codigo
having sum(comp.valor) > 200


