# Elastic search mapping definition for the Molecule entity
from glados.es.ws2es.es_util import DefaultMappings

# Shards size - can be overridden from the default calculated value here
# shards = 3,
replicas = 1

analysis = DefaultMappings.COMMON_ANALYSIS

mappings = \
    {
        'properties': 
        {
            'biocomponents': 
            {
                'properties': 
                {
                    'component_id': 'NUMERIC',
                    # EXAMPLES:
                    # '6578' , '6747' , '8365' , '6474' , '6537' , '6306' , '6383' , '6452' , '6356' , '6567'
                    'component_type': 'TEXT',
                    # EXAMPLES:
                    # 'PROTEIN' , 'PROTEIN' , 'PROTEIN' , 'PROTEIN' , 'PROTEIN' , 'PROTEIN' , 'PROTEIN' , 'PROTEIN' , 'P
                    # ROTEIN' , 'PROTEIN'
                    'description': 'TEXT',
                    # EXAMPLES:
                    # 'Caplacizumab' , 'Enfuvirtide peptide' , 'Fusion protein (human activin receptor type IIb extracel
                    # lular domain/IgG1 Fc domain' , 'Tadocizumab fab fragment' , 'Tenatumomab heavy chain' , 'Teplizuma
                    # b heavy chain' , 'Teprotumumab heavy chain' , 'Tralokinumab heavy chain' , 'Urelumab heavy chain' 
                    # , 'Enokizumab heavy chain'
                    'organism': 'TEXT',
                    # EXAMPLES:
                    # 'Homo sapiens' , 'Mus musculus' , 'Homo sapiens' , 'Homo sapiens' , 'Homo sapiens' , 'Homo sapiens
                    # ' , 'Mus musculus' , 'Homo sapiens' , 'Homo sapiens' , 'Homo sapiens'
                    'sequence': 'TEXT',
                    # EXAMPLES:
                    # 'EVQLVESGGGLVQPGGSLRLSCAASGRTFSYNPMGWFRQAPGKGRELVAAISRTGGSTYYPDSVEGRFTISRDNAKRMVYLQMNSLRAEDTAVYYCA
                    # AAGVRAEDGRVRTLPSEYTFWGQGTQVTVSSAAAEVQLVESGGGLVQPGGSLRLSCAASGRTFSYNPMGWFRQAPGKGRELVAAISRTGGSTYYPDSV
                    # EGRFTISRDNAKRMVYLQMNSLRAEDTAVYYCAAAGVRAEDGRVRTLPSEYTFWGQGTQVTVSS' , 'FWNWLSAWKDLELLEQENKEQQNQSEEIL
                    # SHILSTY' , 'ETRECIYYNANWELERTNQSGLERCEGEQDKRLHCYASWRNSSGTIELVKKGCWDDDFNCYDRQECVATEENPQVYFCCCEGNFCN
                    # ERFTHLPEAGGPEVTYEPPPTGGGTHTCPPCPAPELLGGPSVFLFPPKPKDTLMISRTPEVTCVVVDVSHEDPEVKFNWYVDGVEVHNAKTKPREEQY
                    # NSTYRVVSVLTVLHQDWLNGKEYKCKVSNKALPAPIEKTISKAKGQPREPQVYTLPPSREEMTKNQVSLTCLVKGFYPSDIAVEWESNGQPENNYKTT
                    # PPVLDSDGSFFLYSKLTVDKSRWQQGNVFSCSVMHEALHNHYTQKSLSLSPGK' , 'QVQLVQSGAEVKKPGSSVKVSCKASGYAFTNYLIEWVRQA
                    # PGQGLEWIGVIYPGSGGTNYNEKFKGRVTLTVDESTNTAYMELSSLRSEDTAVYFCARRDGNYGWFAYWGQGTLVTVSSASTKGPSVFPLAPSSKSTS
                    # GGTAALGCLVKDYFPEPVTVSWNSGALTSGVHTFPAVLQSSGLYSLSSVVTVPSSSLGTQTYICNVNHKPSNTKVDKKVEPKSCDKTH' , 'EIQLQ
                    # QSGPELVKPGASVKVSCKASGYAFTSYNMYWVKQSHGKSLEWIGYIDPYNGVTSYNQKFKGKATLTVDKSSSTAYMHLNSLTSEDSAVYYCARGGGSI
                    # YYAMDYWGQGTSVTVSSAKTTPPSVYPLAPGCGDTTGSSVTLGCLVKGYFPESVTVTWNSGSLSSSVHTFPALLQSGLYTMSSSVTVPSSTWPSQTVT
                    # CSVAHPASSTTVDKKLEPSGPISTINPCPPCKECHKCPAPNLEGGPSVFIFPPNIKDVLMISLTPKVTCVVVDVSEDDPDVQISWFVNNVEVHTAQTQ
                    # THREDYNSTIRVVSTLPIQHQDWMSGKEFKCKVNNKDLPSPIERTISKIKGLVRAPQVYILPPPAEQLSRKDVSLTCLVVGFNPGDISVEWTSNGHTE
                    # ENYKDTAPVLDSDGSYFIYSKLNMKTSKWEKTDSFSCNVRHEGLKNYYLKKTISRSPGK' , 'QVQLVQSGGGVVQPGRSLRLSCKASGYTFTRYTM
                    # HWVRQAPGKGLEWIGYINPSRGYTNYNQKVKDRFTISRDNSKNTAFLQMDSLRPEDTGVYFCARYYDDHYCLDYWGQGTPVTVSSASTKGPSVFPLAP
                    # SSKSTSGGTAALGCLVKDYFPEPVTVSWNSGALTSGVHTFPAVLQSSGLYSLSSVVTVPSSSLGTQTYICNVNHKPSNTKVDKKVEPKSCDKTHTCPP
                    # CPAPEAAGGPSVFLFPPKPKDTLMISRTPEVTCVVVDVSHEDPEVKFNWYVDGVEVHNAKTKPREEQYNSTYRVVSVLTVLHQDWLNGKEYKCKVSNK
                    # ALPAPIEKTISKAKGQPREPQVYTLPPSRDELTKNQVSLTCLVKGFYPSDIAVEWESNGQPENNYKTTPPVLDSDGSFFLYSKLTVDKSRWQQGNVFS
                    # CSVMHEALHNHYTQKSLSLSPGK' , 'QVELVESGGGVVQPGRSQRLSCAASGFTFSSYGMHWVRQAPGKGLEWVAIIWFDGSSTYYADSVRGRFTI
                    # SRDNSKNTLYLQMNSLRAEDTAVYFCARELGRRYFDLWGRGTLVSVSSASTKGPSVFPLAPSSKSTSGGTAALGCLVKDYFPEPVTVSWNSGALTSGV
                    # HTFPAVLQSSGLYSLSSVVTVPSSSLGTQTYICNVNHKPSNTKVDKKVEPKSCDKTHTCPPCPAPELLGGPSVFLFPPKPKDTLMISRTPEVTCVVVD
                    # VSHEDPEVKFNWYVDGVEVHNAKTKPREEQYNSTYRVVSVLTVLHQDWLNGKEYKCKVSNKALPAPIEKTISKAKGQPREPQVYTLPPSRDELTKNQV
                    # SLTCLVKGFYPSDIAVEWESNGQPENNYKTTPPVLDSDGSFFLYSKLTVDKSRWQQGNVFSCSVMHEALHNHYTQKSLSLSPGK' , 'QVQLVQSGA
                    # EVKKPGASVKVSCKASGYTFTNYGLSWVRQAPGQGLEWMGWISANNGDTNYGQEFQGRVTMTTDTSTSTAYMELRSLRSDDTAVYYCARDSSSSWARW
                    # FFDLWGRGTLVTVSSASTKGPSVFPLAPCSRSTSESTAALGCLVKDYFPEPVTVSWNSGALTSGVHTFPAVLQSSGLYSLSSVVTVPSSSLGTKTYTC
                    # NVDHKPSNTKVDKRVESKYGPPCPSCPAPEFLGGPSVFLFPPKPKDTLMISRTPEVTCVVVDVSQEDPEVQFNWYVDGVEVHNAKTKPREEQFNSTYR
                    # VVSVLTVLHQDWLNGKEYKCKVSNKGLPSSIEKTISKAKGQPREPQVYTLPPSQEEMTKNQVSLTCLVKGFYPSDIAVEWESNGQPENNYKTTPPVLD
                    # SDGSFFLYSRLTVDKSRWQEGNVFSCSVMHEALHNHYTQKSLSLSLGK' , 'QVQLQQWGAGLLKPSETLSLTCAVYGGSFSGYYWSWIRQSPEKGL
                    # EWIGEINHGGYVTYNPSLESRVTISVDTSKNQFSLKLSSVTAADTAVYYCARDYGPGNYDWYFDLWGRGTLVTVSSASTKGPSVFPLAPCSRSTSEST
                    # AALGCLVKDYFPEPVTVSWNSGALTSGVHTFPAVLQSSGLYSLSSVVTVPSSSLGTKTYTCNVDHKPSNTKVDKRVESKYGPPCPPCPAPEFLGGPSV
                    # FLFPPKPKDTLMISRTPEVTCVVVDVSQEDPEVQFNWYVDGVEVHNAKTKPREEQFNSTYRVVSVLTVLHQDWLNGKEYKCKVSNKGLPSSIEKTISK
                    # AKGQPREPQVYTLPPSQEEMTKNQVSLTCLVKGFYPSDIAVEWESNGQPENNYKTTPPVLDSDGSFFLYSRLTVDKSRWQEGNVFSCSVMHEALHNHY
                    # TQKSLSLSLGK' , 'QVQLVQSGAEVKKPGSSVKVSCKASGGTFSYYWIEWVRQAPGQGLEWMGEILPGSGTTNPNEKFKGRVTITADESTSTAYME
                    # LSSLRSEDTAVYYCARADYYGSDYVKFDYWGQGTLVTVSSASTKGPSVFPLAPSSKSTSGGTAALGCLVKDYFPEPVTVSWNSGALTSGVHTFPAVLQ
                    # SSGLYSLSSVVTVPSSSLGTQTYICNVNHKPSNTKVDKRVEPKSCDKTHTCPPCPAPELLGGPSVFLFPPKPKDTLMISRTPEVTCVVVDVSHEDPEV
                    # KFNWYVDGVEVHNAKTKPREEQYNSTYRVVSVLTVLHQDWLNGKEYKCKVSNKALPAPIEKTISKAKGQPREPQVYTLPPSREEMTKNQVSLTCLVKG
                    # FYPSDIAVEWESNGQPENNYKTTPPVLDSDGSFFLYSKLTVDKSRWQQGNVFSCSVMHEALHNHYTQKSLSLSPGK'
                    'tax_id': 'NUMERIC',
                    # EXAMPLES:
                    # '9606' , '10090' , '9606' , '9606' , '9606' , '9606' , '10090' , '9606' , '9606' , '9606'
                }
            },
            'description': 'TEXT',
            # EXAMPLES:
            # 'MELITTIN' , 'ENKEPHALIN' , '[Val5] - ANGIOTENSIN II' , 'MAGAININ 2' , 'PRALMORELIN' , 'EXAMORELIN' , 'NEU
            # ROPEPTIDE-Y' , 'NPY[TYR32,LEU34]' , 'Immunoglobulin G2, anti-(human tumor necrosis factor ligand superfami
            # ly member 11 (human osteoclast differentiation factor))(human monoclonal AMG162 heavy chain), disulfide wi
            # th human monoclonal AMG162 light chain, dimer' , 'LIGNESFAL'
            'helm_notation': 'TEXT',
            # EXAMPLES:
            # 'PEPTIDE1{A.L.Y.A.S.K.L.S.[am]}$$$$' , 'PEPTIDE1{[meR].K.P.W.[Tle].L}$$$$' , 'PEPTIDE1{[X833].[dP].W.[Tle]
            # .[X454]}$$$$' , 'PEPTIDE1{[X12].[dP].W.[Tle].[X454]}$$$$' , 'PEPTIDE1{K.P.W.[Tle].L}$$$$' , 'PEPTIDE1{[X12
            # ].[dP].W.I.L}$$$$' , 'PEPTIDE1{[X500].[dP].W.[Tle].[X454]}$$$$' , 'PEPTIDE1{K.F.Y.C.N.G.K.R.V.C.V.C.R.[am]
            # }$$$$' , 'PEPTIDE1{G.R.G.D.S.P}$$$$' , 'PEPTIDE1{[X12].[dP].Y.[Tle].L}$$$$'
            'molecule_chembl_id': 'TEXT',
            # EXAMPLES:
            # 'CHEMBL448105' , 'CHEMBL266571' , 'CHEMBL268600' , 'CHEMBL6562' , 'CHEMBL380726' , 'CHEMBL427604' , 'CHEMB
            # L265671' , 'CHEMBL266306' , 'CHEMBL6602' , 'CHEMBL6508'
        }
    }
