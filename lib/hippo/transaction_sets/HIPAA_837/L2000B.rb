module Hippo::TransactionSets
  module HIPAA_837

    class L2000B < Hippo::TransactionSets::Base
      loop_name 'L2000B'    #Subscriber Hierarchical Level

      #Subscriber Hierarchical Level
      segment Hippo::Segments::HL,
                :name           => 'Subscriber Hierarchical Level',
                :minimum        => 1,
                :maximum        => 1,
                :position       => 10,
                :defaults => {
                  'HL03' => '22'
                }

      #Subscriber Information
      segment Hippo::Segments::SBR,
                :name           => 'Subscriber Information',
                :minimum        => 1,
                :maximum        => 1,
                :position       => 50

      #Patient Information
      segment Hippo::Segments::PAT,
                :name           => 'Patient Information',
                :minimum        => 0,
                :maximum        => 1,
                :position       => 70

      #Subscriber Name
      loop    Hippo::TransactionSets::HIPAA_837::L2010BA,
                :name           => 'Subscriber Name',
                :identified_by  => {'NM1.NM101' => 'IL'},
                :minimum        => 1,
                :maximum        => 1,
                :position       => 150

      #Payer Name
      loop    Hippo::TransactionSets::HIPAA_837::L2010BB,
                :name           => 'Payer Name',
                :identified_by  => {'NM1.NM101' => 'PR'},
                :minimum        => 1,
                :maximum        => 1,
                :position       => 150

      #Patient Hierarchical Level - Used if the patient is not the subscriber
      loop    Hippo::TransactionSets::HIPAA_837::L2000C,
                :name           => 'Patient Hierarchical Level',
                :identified_by  => {
                  'HL.HL03' => '23'
                },
                :minimum        => 0,
                :maximum        => 99999,
                :position       => 10

      #Claim Information - Used if the subcriber is the patient
      loop    Hippo::TransactionSets::HIPAA_837::L2300,
                :name           => 'Claim Information',
                :minimum        => 1,
                :maximum        => 100,
                :position       => 1300

    end
  end
end
