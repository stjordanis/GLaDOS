# Elastic search mapping definition for the Molecule entity
from glados.ws2es.es_util import DefaultMappings

# Shards size - can be overridden from the default calculated value here
# shards = 3,
replicas = 1

analysis = DefaultMappings.COMMON_ANALYSIS

mappings = \
    {
        '_doc': 
        {
            'properties': 
            {
                'biocomponents': 
                {
                    'properties': 
                    {
                        'component_id': 'NUMERIC',
                        # EXAMPLES:
                        # '6377' , '6302' , '6347' , '6476' , '6421' , '6431' , '6310' , '6520' , '6539' , '6501'
                        'component_type': 'TEXT',
                        # EXAMPLES:
                        # 'PROTEIN' , 'PROTEIN' , 'PROTEIN' , 'PROTEIN' , 'PROTEIN' , 'PROTEIN' , 'PROTEIN' , 'PROTEIN' 
                        # , 'PROTEIN' , 'PROTEIN'
                        'description': 'TEXT',
                        # EXAMPLES:
                        # 'Dalotuzumab heavy chain' , 'Daratumumab heavy chain' , 'Efungumab single chain variable fragm
                        # ent' , 'Etaracizumab heavy chain' , 'Farletuzumab heavy chain' , 'Ficlatuzumab heavy chain' , 
                        # 'Foralumab heavy chain' , 'Foravirumab heavy chain' , 'Fresolimumab heavy chain' , 'Fulranumab
                        #  heavy chain'
                        'organism': 'TEXT',
                        # EXAMPLES:
                        # 'Homo sapiens' , 'Homo sapiens' , 'Homo sapiens' , 'Homo sapiens' , 'Homo sapiens' , 'Homo sap
                        # iens' , 'Homo sapiens' , 'Homo sapiens' , 'Homo sapiens' , 'Homo sapiens'
                        'sequence': 'TEXT',
                        # EXAMPLES:
                        # 'QVQLQQSGPGLVKPSQTLSLTCTVSGWSISGGWLWNWIRQPPGKGLQWIGWISWDGTNNWKPSLKDRVTISVDTSKNQFSLKLSSVTAADTAV
                        # WWCARWGRVFFDWWGQGTLVTVSSASTKGPSVFPLAPSSKSTSGGTAALGCLVKDYFPEPVTVSWNSGALTSGVHTFPAVLQSSGLYSLSSVVT
                        # VPSSSLGTQTYICNVNHKPSNTKVDKRVEPKSCDKTHTCPPCPAPELLGGPSVFLFPPKPKDTLMISRTPEVTCVVVDVSHEDPEVKFNWYVDG
                        # VEVHNAKTKPREEQYNSTYRVVSVLTVLHQDWLNGKEYKCKVSNKALPAPIEKTISKAKGQPREPQVYTLPPSREEMTKNQVSLTCLVKGFYPS
                        # DIAVEWESNGQPENNYKTTPPVLDSDGSFFLYSKLTVDKSRWQQGNVFSCSVMHEALHNHYTQKSLSLSPGK' , 'EVQLLESGGGLVQPGGS
                        # LRLSCAVSGFTFNSFAMSWVRQAPGKGLEWVSAISGSGGGTYYADSVKGRFTISRDNSKNTLYLQMNSLRAEDTAVYFCAKDKILWFGEPVFDY
                        # WGQGTLVTVSSASTKGPSVFPLAPSSKSTSGGTAALGCLVKDYFPEPVTVSWNSGALTSGVHTFPAVLQSSGLYSLSSVVTVPSSSLGTQTYIC
                        # NVNHKPSNTKVDKRVEPKSCDKTHTCPPCPAPELLGGPSVFLFPPKPKDTLMISRTPEVTCVVVDVSHEDPEVKFNWYVDGVEVHNAKTKPREE
                        # QYNSTYRVVSVLTVLHQDWLNGKEYKCKVSNKALPAPIEKTISKAKGQPREPQVYTLPPSREEMTKNQVSLTCLVKGFYPSDIAVEWESNGQPE
                        # NNYKTTPPVLDSDGSFFLYSKLTVDKSRWQQGNVFSCSVMHEALHNHYTQKSLSLSPGK' , 'MAEVQLVESGAEVKKPGESLRISCKGSGCI
                        # ISSYWISWVRQMPGKGLEWMGKIDPGDSYINYSPSFQGHVTISADKSINTAYLQWNSLKASDTAMYYCARGGRDFGDSFDYWGQGTLVTVSSGG
                        # GGSGGGGSGGGGSDVVMTQSPSFLSAFVGDRITITCRASSGISRYLAWYQQAPGKAPKLLIYAASTLQTGVPSRFSGSGSGTEFTLTINSLQPE
                        # DFATYYCQHLNSYPLTFGGGTKVDIKRAAALEHHHHHH' , 'QVQLVESGGGVVQPGRSLRLSCAASGFTFSSYDMSWVRQAPGKGLEWVAKV
                        # SSGGGSTYYLDTVQGRFTISRDNSKNTLYLQMNSLRAEDTAVYYCARHLHGSFASWGQGTTVTVSSASTKGPSVFPLAPSSKSTSGGTAALGCL
                        # VKDYFPEPVTVSWNSGALTSGVHTFPAVLQSSGLYSLSSVVTVPSSSLGTQTYICNVNHKPSNTKVDKRVEPKSCDKTHTCPPCPAPELLGGPS
                        # VFLFPPKPKDTLMISRTPEVTCVVVDVSHEDPEVKFNWYVDGVEVHNAKTKPREEQYNSTYRVVSVLTVLHQDWLNGKEYKCKVSNKALPAPIE
                        # KTISKAKGQPREPQVYTLPPSREEMTKNQVSLTCLVKGFYPSDIAVEWESNGQPENNYKTTPPVLDSDGSFFLYSKLTVDKSRWQQGNVFSCSV
                        # MHEALHNHYTQKSLSLSPGK' , 'EVQLVESGGGVVQPGRSLRLSCSASGFTFSGYGLSWVRQAPGKGLEWVAMISSGGSYTYYADSVKGRFA
                        # ISRDNAKNTLFLQMDSLRPEDTGVYFCARHGDDPAWFAYWGQGTPVTVSSASTKGPSVFPLAPSSKSTSGGTAALGCLVKDYFPEPVTVSWNSG
                        # ALTSGVHTFPAVLQSSGLYSLSSVVTVPSSSLGTQTYICNVNHKPSNTKVDKKVEPKSCDKTHTCPPCPAPELLGGPSVFLFPPKPKDTLMISR
                        # TPEVTCVVVDVSHEDPEVKFNWYVDGVEVHNAKTKPREEQYNSTYRVVSVLTVLHQDWLNGKEYKCKVSNKALPAPIEKTISKAKGQPREPQVY
                        # TLPPSRDELTKNQVSLTCLVKGFYPSDIAVEWESNGQPENNYKTTPPVLDSDGSFFLYSKLTVDKSRWQQGNVFSCSVMHEALHNHYTQKSLSL
                        # SPGK' , 'VQLVQPGAEVKKPGTSVKLSCKASGYTFTTYWMHWVRQAPGQGLEWIGEINPTNGHTNYNQKFQGRATLTVDKSTSTAYMELSSL
                        # RSEDTAVYYCARNYVGSIFDYWGQGTLLTVSSASTKGPSVFPLAPSSKSTSGGTAALGCLVKDYFPEPVTVSWNSGALTSGVHTFPAVLQSSGL
                        # YSLSSVVTVPSSSLGTQTYICNVNHKPSNTKVDKRVEPKSCDKTHTCPPCPAPELLGGPSVFLFPPKPKDTLMISRTPEVTCVVVDVSHEDPEV
                        # KFNWYVDGVEVHNAKTKPREEQYNSTYRVVSVLTVLHQDWLNGKEYKCKVSNKALPAPIEKTISKAKGQPREPQVYTLPPSREEMTKNQVSLTC
                        # LVKGFYPSDIAVEWESNGQPENNYKTTPPVLDSDGSFFLYSKLTVDKSRWQQGNVFSCSVMHEALHNHYTQKSLSLSPGK' , 'QVQLVESGG
                        # GVVQPGRSLRLSCAASGFKFSGYGMHWVRQAPGKGLEWVAVIWYDGSKKYYVDSVKGRFTISRDNSKNTLYLQMNSLRAEDTAVYYCARQMGYW
                        # HFDLWGRGTLVTVSSASTKGPSVFPLAPSSKSTSGGTAALGCLVKDYFPEPVTVSWNSGALTSGVHTFPAVLQSSGLYSLSSVVTVPSSSLGTQ
                        # TYICNVNHKPSNTKVDKRVEPKSCDKTHTCPPCPAPEAEGGPSVFLFPPKPKDTLMISRTPEVTCVVVDVSHEDPEVKFNWYVDGVEVHNAKTK
                        # PREEQYNSTYRVVSVLTVLHQDWLNGKEYKCKVSNKALPAPIEKTISKAKGQPREPQVYTLPPSREEMTKNQVSLTCLVKGFYPSDIAVEWESN
                        # GQPENNYKTTPPVLDSDGSFFLYSKLTVDKSRWQQGNVFSCSVMHEALHNHYTQKSLSLSPGK' , 'EVQLVESGGGAVQPGRSLRLSCAASG
                        # FTFSSYGMHWVRQAPGKGLEWVAVILYDGSDKFYADSVKGRFTISRDNSKNTLYLQMNSLRAEDTAVYYCAKVAVAGTHFDYWGQGTLVTVSSA
                        # STKGPSVFPLAPSSKSTSGGTAALGCLVKDYFPEPVTVSWNSGALTSGVHTFPAVLQSSGLYSLSSVVTVPSSSLGTQTYICNVNHKPSNTKVD
                        # KRVEPKSCDKTHTCPPCPAPELLGGPSVFLFPPKPKDTLMISRTPEVTCVVVDVSHEDPEVKFNWYVDGVEVHNAKTKPREEQYNSTYRVVSVL
                        # TVLHQDWLNGKEYKCKVSNKALPAPIEKTISKAKGQPREPQVYTLPPSREEMTKNQVSLTCLVKGFYPSDIAVEWESNGQPENNYKTTPPVLDS
                        # DGSFFLYSKLTVDKSRWQQGNVFSCSVMHEALHNHYTQKSLSLSPG' , 'QVQLVQSGAEVKKPGSSVKVSCKASGYTFSSNVISWVRQAPGQ
                        # GLEWMGGVIPIVDIANYAQRFKGRVTITADESTSTTYMELSSLRSEDTAVYYCASTLGLVLDAMDYWGQGTLVTVSSASTKGPSVFPLAPCSRS
                        # TSESTAALGCLVKDYFPEPVTVSWNSGALTSGVHTFPAVLQSSGLYSLSSVVTVPSSSLGTKTYTCNVDHKPSNTKVDKRVESKYGPPCPSCPA
                        # PEFLGGPSVFLFPPKPKDTLMISRTPEVTCVVVDVSQEDPEVQFNWYVDGVEVHNAKTKPREEQFNSTYRVVSVLTVLHQDWLNGKEYKCKVSN
                        # KGLPSSIEKTISKAKGQPREPQVYTLPPSQEEMTKNQVSLTCLVKGFYPSDIAVEWESNGQPENNYKTTPPVLDSDGSFFLYSRLTVDKSRWQE
                        # GNVFSCSVMHEALHNHYTQKSLSLSLGK' , 'EVQLVESGGGLVQPGGSLRLSCAASGFTLRSYSMNWVRQAPGKGLEWVSYISRSSHTIFYA
                        # DSVKGRFTISRDNAKNSLYLQMDSLRDEDTAMYYCARVYSSGWHVSDYFDYWGQGILVTVSSASTKGPSVFPLAPCSRSTSESTAALGCLVKDY
                        # FPEPVTVSWNSGALTSGVHTFPAVLQSSGLYSLSSVVTVPSSNFGTQTYTCNVDHKPSNTKVDKTVERKCCVECPPCPAPPVAGPSVFLFPPKP
                        # KDTLMISRTPEVTCVVVDVSHEDPEVQFNWYVDGVEVHNAKTKPREEQFNSTFRVVSVLTVVHQDWLNGKEYKCKVSNKGLPAPIEKTISKTKG
                        # QPREPQVYTLPPSREEMTKNQVSLTCLVKGFYPSDIAVEWESNGQPENNYKTTPPMLDSDGSFFLYSKLTVDKSRWQQGNVFSCSVMHEALHNH
                        # YTQKSLSLSPGK'
                        'tax_id': 'NUMERIC',
                        # EXAMPLES:
                        # '9606' , '9606' , '9606' , '9606' , '9606' , '9606' , '9606' , '9606' , '9606' , '9606'
                    }
                },
                'description': 'TEXT',
                # EXAMPLES:
                # 'MAGRSGDSDEELLKT' , 'SGDSDEELLKTVRLI' , 'DEELLKTVRLIKFLY' , 'PRAZARELIX' , 'Follicular lymphoma-derive
                # d immunoglobulin idiotype protein conjugated to keyhole limpet hemacyanine' , 'Guselkumab (human mab)'
                #  , 'PHAKELLISTATIN 12' , 'Tovetumab (human mab)' , 'Vantictumab (human mab)' , 'ABARELIX'
                'helm_notation': 'TEXT',
                # EXAMPLES:
                # 'PEPTIDE1{R.P.[dK].P.Q.[dQ].F.[dF].G.L.M.[am]}$$$$' , 'PEPTIDE1{[meA].[dV].[P_OBzl]}$$$$' , 'PEPTIDE1{
                # T.G.H.F.G.G.L.Y.P}$$$$' , 'PEPTIDE1{R.P.K.P.Q.Q.[dW].F.[dW].L.[dM]}$$$$' , 'PEPTIDE1{E.S.T.R.P.M}$$$$'
                #  , 'PEPTIDE1{G.C.C.S.Y.P.P.C.F.A.T.N.P.D.[X1460]}$$$$' , 'PEPTIDE1{T.A.V.Q.[dM].A.V.F.I.H.N.F.K.R.K}$$
                # $$' , 'PEPTIDE1{[ac].E.D.D.D.W.D.F}$$$$' , 'PEPTIDE1{R.P.[dK].[dP].[dQ].Q.[dF].[dF].G.[dL].M.[am]}$$$$
                # ' , 'PEPTIDE1{[meA].[X711].[P_OBzl]}$$$$'
                'molecule_chembl_id': 'TEXT',
                # EXAMPLES:
                # 'CHEMBL386026' , 'CHEMBL1624734' , 'CHEMBL498954' , 'CHEMBL2304097' , 'CHEMBL143185' , 'CHEMBL429557' 
                # , 'CHEMBL3221998' , 'CHEMBL2348054' , 'CHEMBL412545' , 'CHEMBL1625425'
            }
        }
    }
