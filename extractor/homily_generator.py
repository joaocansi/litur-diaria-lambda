from config import openai_client

def generate_homily(liturgia_completa):
    prompt = f"""
        Crie uma reflexão espiritual católica (como uma homilia) baseada no seguinte trecho do Evangelho: {liturgia_completa}.
        
        Siga exatamente esta estrutura:
        1. Saudação inicial breve e amorosa aos fiéis, como "Queridos irmãos e irmãs".
        2. Introdução situando o Evangelho no contexto litúrgico (tempo, festa ou dia especial) e anunciando o tema principal.
        3. Narração e explicação do Evangelho:
            - Resuma e comente os principais acontecimentos do trecho.
            - Destaque personagens, símbolos e mensagens importantes.
            - Inclua no mínimo uma citação direta do Evangelho, destacada com a tag <strong>.
        4. Aplicação prática:
            - Mostre o que o Evangelho ensina para a vida cristã hoje.
            - Convide à reflexão pessoal e à mudança de vida.
            - Destaque pontos-chave da aplicação com a tag <strong>.
        5. Convite final:
            - Incentive a viver o ensinamento do Evangelho no dia a dia.
            - Destaque a importância do testemunho cristão.
        6. Bênção final:
            - Invoque a Santíssima Trindade explicitamente, com destaque para "em nome do Pai, do Filho e do Espírito Santo" usando <strong>.

        Instruções de estilo:
        - Não deve citar a palavra homilia.
        - Linguagem próxima, amorosa e pastoral, mas sem ser informal e sem usar a primeira pessoa ("eu", "meu", etc.).
        - Cada parágrafo deve se conectar de maneira fluída e natural.
        - Texto entre 400 e 600 palavras.
        - Comece o texto com um título dentro da tag <h3>, antes do primeiro parágrafo <p>.
        - Respeite a estrutura de parágrafos HTML (<p>) e destaque trechos importantes com <strong>.
        - O tom deve ser respeitoso, contemplativo e acolhedor, como uma pregação de Missa.

        Formato de saída: HTML simples, usando apenas <p> e <h3> (para o título da homilia apenas) e <strong> quando necessário.
    """
    completion = openai_client.chat.completions.create(
        model="gpt-4o-mini",
        temperature=0.7,
        messages=[{"role": "system", "content": "Você é um teólogo cristão que escreve reflexões espirituais diárias."},
                  {"role": "user", "content": prompt}]
    )
    reflexao = completion.choices[0].message.content.strip()
    return reflexao
