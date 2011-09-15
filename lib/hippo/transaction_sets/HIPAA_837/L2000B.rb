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
                :identified_by => {
                  'HL03' => '22',
                  'HL04' => ["0", "1"]
                }

      #Subscriber Information
      segment Hippo::Segments::SBR,
                :name           => 'Subscriber Information',
                :minimum        => 1,
                :maximum        => 1,
                :position       => 50,
                :identified_by => {
                  'SBR01' => ["A", "B", "C", "D", "E", "F", "G", "H", "P", "S", "T", "U"]
                }

      #Patient Information
      segment Hippo::Segments::PAT,
                :name           => 'Patient Information',
                :minimum        => 0,
                :maximum        => 1,
                :position       => 70

      #Subscriber Name
      loop    Hippo::TransactionSets::HIPAA_837::L2010BA,
                :name           => 'Subscriber Name',
                :minimum        => 1,
                :maximum        => 1,
                :position       => 150,
                :identified_by  => {'NM1.NM101' => 'IL'}

      #Payer Name
      loop    Hippo::TransactionSets::HIPAA_837::L2010BB,
                :name           => 'Payer Name',
                :minimum        => 1,
                :maximum        => 1,
                :position       => 150,
                :identified_by  => {'NM1.NM101' => 'PR'}

      #Patient Hierarchical Level
      loop    Hippo::TransactionSets::HIPAA_837::L2000C,
                :name           => 'Patient Hierarchical Level',
                :minimum        => 0,
                :maximum        => 99999,
                :position       => 10,
                :identified_by  => {'HL.HL03' => '23'}

      #Claim Information
      loop    Hippo::TransactionSets::HIPAA_837::L2300,
                :name           => 'Claim Information',
                :minimum        => 1,
                :maximum        => 100,
                :position       => 1300

    end
  end
end
