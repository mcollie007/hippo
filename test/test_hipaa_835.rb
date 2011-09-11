require File.join(File.dirname(__FILE__), 'test_helper')

class TestHIPAA835 < MiniTest::Unit::TestCase

  def test_business_scenario_1
=begin

Dollars and data are being sent together through the banking system to pay
Medicare Part A institutional claims.

This scenario depicts the use of the ANSI ASC X12 835 in a governmental
institutional environment. The electronic transmission of funds request
and the remittance detail are contained within this single 835. In this
scenario, one or more Depository Financial Institutions is involved in 
transferring information from the sender to the receiver.

The following assumptions pertain to scenario one:
• The dollars move using the ACH network from the Bank of Payorea, 
  ABA# 999999992, account number 123456 to the Bank of No Return,
  ABA# 999988880, checking account number 98765. The money moves on
  September 13, 2002.
• The Insurance Company of Timbucktu, Federal tax ID # 512345678 and
  Medicare Intermediary ID# 999, is paying Regional Hope Hospital, National
  Provider Number 6543210903. This is for one inpatient and one outpatient claim.
• For the inpatient claim, the patient’s name is Sam O. Jones. The Health
  Insurance Claim Number is 666-66-6666A. The Claim Submitter’s Identifier is
  666123. The date of the hospitalization was August 16, 2002 to August 24, 2002.
  Total charges reported are $211,366.97. Paid amount is $138,018.40. There is
  no patient responsibility. Contractual adjustment is $73,348.57. No service
  line detail is provided.
• For the outpatient claim, the patient’s name is Liz E. Border, Health
  Insurance Claim Number 996-66-9999B. The Claim Submitter’s Identifier is
  777777. The date of service is May 12, 2002. Total charges reported are 
  $15,000. Paid amount is $11,980.33. Contractual adjustment is $3,019.67.
  There is no service line information.
• There is a Capital Pass Through Amount (CV) payment to the provider for $1.27.

=end

    ts = Hippo::TransactionSets::HIPAA_835::Base.new

    ts.ST do |st|
      st.TransactionSetControlNumber        = '1234'
    end

    ts.BPR do |bpr|
      bpr.TransactionHandlingCode           = 'C'
      bpr.MonetaryAmount                    = '150000'
      bpr.CreditDebitFlagCode               = 'C'
      bpr.PaymentMethodCode                 = 'ACH'
      bpr.PaymentFormatCode                 = 'CTX'
      bpr.DfiIdNumberQualifier              = '01'
      bpr.DfiIdentificationNumber           = '999999992'
      bpr.AccountNumberQualifier            = 'DA'
      bpr.AccountNumber                     = '123456'
      bpr.OriginatingCompanyIdentifier      = '1512345678'
      bpr.DfiIdNumberQualifier_02           = '01'
      bpr.DfiIdentificationNumber_02        = '999988880'
      bpr.AccountNumberQualifier_02         = 'DA'
      bpr.AccountNumber_02                  = '98765'
      bpr.Date                              = '20020913'
    end

    ts.TRN do |trn|
      trn.ReferenceIdentification           = '12345'
      trn.OriginatingCompanyIdentifier      = '1512345678'
    end

    ts.DTM.Date = '20020916'

    ts.L1000A do |l1000a|
      l1000a.N1.Name                = 'INSURANCE COMPANY OF TIMBUCKTU'
      l1000a.N3.AddressInformation  = '1 MAIN STREET'

      l1000a.N4 do |n4|
        n4.CityName                 = 'TIMBUCKTU'
        n4.StateOrProvinceCode      = 'AK'
        n4.PostalCode               = '89111'
      end

      l1000a.REF do |ref|
        ref.ReferenceIdentificationQualifier  = '2U'
        ref.ReferenceIdentification           = '999'
      end
    end

    ts.L1000B do |l1000b|
      l1000b.N1 do |n1|
        n1.Name                         = 'REGIONAL HOPE HOSPITAL'
        n1.IdentificationCodeQualifier  = 'XX'
        n1.IdentificationCode           = '6543210903'
      end
    end

    ts.L2000.build do |l2000|
      l2000.LX.LX01 = '110212'

      l2000.TS3 do |ts3|
        ts3.ReferenceIdentification     = '6543210903'
        ts3.FacilityCodeValue           = '11'
        ts3.Date                        = '20021231'
        ts3.Quantity                    = '1'
        ts3.MonetaryAmount_01           = '211366.97'
        ts3.MonetaryAmount_05           = '138018.4'
        ts3.MonetaryAmount_07           = '73348.57'
      end

      l2000.TS2 do |ts2|
        ts2.MonetaryAmount_01           = '2178.45'
        ts2.MonetaryAmount_02           = '1919.71'
        ts2.MonetaryAmount_04           = '56.82'
        ts2.MonetaryAmount_05           = '197.69'
        ts2.MonetaryAmount_06           = '4.23'
      end

      l2000.L2100.build do |l2100|
        l2100.CLP do |clp|
          clp.ClaimSubmitterSIdentifier = '666123'
          clp.ClaimStatusCode           = '1'
          clp.MonetaryAmount_01         = '211366.97'
          clp.MonetaryAmount_02         = '138018.4'
          clp.ClaimFilingIndicatorCode  = 'MA'
          clp.ReferenceIdentification   = '1999999444444'
          clp.FacilityCodeValue         = '11'
          clp.ClaimFrequencyTypeCode    = '1'
        end

        l2100.CAS.build do |cas|
          cas.ClaimAdjustmentGroupCode  = 'CO'
          cas.ClaimAdjustmentReasonCode = '45'
          cas.MonetaryAmount            = '73348.57'
        end

        l2100.NM1 do |nm1|
          nm1.NameLastOrOrganizationName  = 'JONES'
          nm1.NameFirst                   = 'SAM'
          nm1.NameMiddle                  = 'O'
          nm1.IdentificationCodeQualifier = 'HN'
          nm1.IdentificationCode          = '666666666A'
        end

        l2100.MIA do |mia|
          mia.Quantity                    = '0'
          mia.MonetaryAmount_02           = '138018.4'
        end

        l2100.DTM_01.build do |dtm|
          dtm.DateTimeQualifier           = '232'
          dtm.Date                        = '20020816'
        end

        l2100.DTM_01.build do |dtm|
          dtm.DateTimeQualifier           = '233'
          dtm.Date                        = '20020824'
        end

        l2100.QTY do |qty|
          qty.QuantityQualifier           = 'CA'
          qty.Quantity                    = '8'
        end
      end
    end

    ts.L2000.build do |l2000|
      l2000.LX.LX01 = '130212'

      l2000.TS3 do |ts3|
        ts3.ReferenceIdentification     = '6543210909'
        ts3.FacilityCodeValue           = '13'
        ts3.Date                        = '19961231'
        ts3.Quantity                    = '1'
        ts3.MonetaryAmount_01           = '15000'
        ts3.MonetaryAmount_05           = '11980.33'
        ts3.MonetaryAmount_07           = '3019.67'
      end

      l2000.L2100.build do |l2100|
        l2100.CLP do |clp|
          clp.ClaimSubmitterSIdentifier = '777777'
          clp.ClaimStatusCode           = '1'
          clp.MonetaryAmount_01         = '15000'
          clp.MonetaryAmount_02         = '11980.33'
          clp.ClaimFilingIndicatorCode  = 'MB'
          clp.ReferenceIdentification   = '1999999444445'
          clp.FacilityCodeValue         = '13'
          clp.ClaimFrequencyTypeCode    = '1'
        end

        l2100.CAS.build do |cas|
          cas.ClaimAdjustmentGroupCode  = 'CO'
          cas.ClaimAdjustmentReasonCode = '45'
          cas.MonetaryAmount            = '3019.67'
        end

        l2100.NM1 do |nm1|
          nm1.NameLastOrOrganizationName  = 'BORDER'
          nm1.NameFirst                   = 'LIZ'
          nm1.NameMiddle                  = 'E'
          nm1.IdentificationCodeQualifier = 'HN'
          nm1.IdentificationCode          = '996669999B'
        end

        l2100.MOA do |moa|
          moa.ReferenceIdentification     = 'MA02'
        end

        l2100.DTM_01.build do |dtm|
          dtm.DateTimeQualifier           = '232'
          dtm.Date                        = '20020512'
        end
      end
    end

    ts.PLB do |plb|
      plb.ReferenceIdentification_01  = '6543210903'
      plb.Date                        = '20021231'
      plb.AdjustmentReasonCode        = 'CV'
      plb.ReferenceIdentification_02  = 'CP'
      plb.MonetaryAmount              = '-1.27'
    end

    ts.SE.TransactionSetControlNumber = ts.ST.TransactionSetControlNumber
    ts.SE.NumberOfIncludedSegments    = ts.segment_count

    provided_answer = <<EOF
ST*835*1234~
BPR*C*150000*C*ACH*CTX*01*999999992*DA*123456*1512345678**01*999988880*DA*98765*20020913~
TRN*1*12345*1512345678~
DTM*405*20020916~
N1*PR*INSURANCE COMPANY OF TIMBUCKTU~
N3*1 MAIN STREET~
N4*TIMBUCKTU*AK*89111~
REF*2U*999~
N1*PE*REGIONAL HOPE HOSPITAL*XX*6543210903~
LX*110212~
TS3*6543210903*11*20021231*1*211366.97****138018.4**73348.57~
TS2*2178.45*1919.71**56.82*197.69*4.23~
CLP*666123*1*211366.97*138018.4**MA*1999999444444*11*1~
CAS*CO*45*73348.57~
NM1*QC*1*JONES*SAM*O***HN*666666666A~
MIA*0***138018.4~
DTM*232*20020816~
DTM*233*20020824~
QTY*CA*8~
LX*130212~
TS3*6543210909*13*19961231*1*15000****11980.33**3019.67~
CLP*777777*1*15000*11980.33**MB*1999999444445*13*1~
CAS*CO*45*3019.67~
NM1*QC*1*BORDER*LIZ*E***HN*996669999B~
MOA***MA02~
DTM*232*20020512~
PLB*6543210903*20021231*CV:CP*-1.27~
SE*28*1234~
EOF

    assert_equal provided_answer, ts.to_s.split('~').join("~\n") + "~\n"
  end
end
