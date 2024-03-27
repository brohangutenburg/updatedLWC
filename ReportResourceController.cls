public with sharing class ReportResourceController {

    public class Reporter {
        public List<String> runListW {get; set;}
        public List<String> runListS {get; set;}
        public Map<String, Decimal> counts {get; set;}
        public Map<String, Decimal> workgroupTotals {get; set;}
        public Map<String, Decimal> stageTotals {get; set;}
        public Set<String> workgroupSet {get; set;}
        public Set<String> stagenameSet {get; set;}

        public Reporter() {
            workgroupSet = new Set<String>();
            stagenameSet = new Set<String>();
            counts = new Map<String, Decimal>();
            workgroupTotals = new Map<String, Decimal>();
            stageTotals = new Map<String, Decimal>();
            createCrossTabData();
        }

        public void createCrossTabData() {
            List<resultMatrix> opportunityMatrix = getOpportunityMatrix();

            for (resultMatrix result : opportunityMatrix) {
                String workgroup = result.WorkGroup;
                String stage = result.StageName;
                Decimal amount = result.Amount;

                workgroupSet.add(workgroup);
                stagenameSet.add(stage);

                String key = workgroup + '-' + stage;
                counts.put(key, amount);

                if (workgroupTotals.containsKey(workgroup)) {
                    workgroupTotals.put(workgroup, workgroupTotals.get(workgroup) + amount);
                } else {
                    workgroupTotals.put(workgroup, amount);
                }

                if (stageTotals.containsKey(stage)) {
                    stageTotals.put(stage, stageTotals.get(stage) + amount);
                } else {
                    stageTotals.put(stage, amount);
                }
            }
            runListW = new List<String>(workgroupSet);
            runListW.sort();
            runListS = new List<String>(stagenameSet);
            runListS.sort();
        }

        public Decimal getTotal() {
            Decimal total = 0;
            for (Decimal workgroupTotal : workgroupTotals.values()) {
                total += workgroupTotal;
            }
            return total;
        }

        public List<resultMatrix> getOpportunityMatrix() {
            List<resultMatrix> oppToStore = new List<resultMatrix>();
            for (AggregateResult result : [
                SELECT Work_Group__c, StageName, SUM(Amount)
                FROM OPPORTUNITY
                WHERE Work_Group__c IN ('Medical', 'Safety', 'Inspection', 'Professional Services')
                GROUP BY Work_Group__c, StageName
            ]) {
                resultMatrix objResultMatrix = new resultMatrix(result); 
                oppToStore.add(objResultMatrix);
            }
            return oppToStore;
        }
    }

    public class ReportResource {
        public List<String> runListW {get; set;}
        public List<String> runListS {get; set;}
        public Map<String, Decimal> counts {get; set;}
        public Map<String, Decimal> workgroupTotals {get; set;}
        public Map<String, Decimal> stageTotals {get; set;}
        public Set<String> workgroupSet {get; set;}
        public Set<String> stagenameSet {get; set;}

        public reportResource() {
            createCrossTabData();
        }

        public void createCrossTabData() {
            Reporter reporter = new Reporter();
            this.runListW = reporter.runListW;
            this.runListS = reporter.runListS;
            this.counts = reporter.counts;
            this.workgroupTotals = reporter.workgroupTotals;
            this.stageTotals = reporter.stageTotals;
            this.workgroupSet = reporter.workgroupSet;
            this.stagenameSet = reporter.stagenameSet;
        }

        public Decimal getTotal() {
            Decimal total = 0;
            for (Decimal workgroupTotal : workgroupTotals.values()) {
                total += workgroupTotal;
            }
            return total;
        }
    }

    public static class resultMatrix {
        public String WorkGroup { get; set; }
        public String StageName { get; set; }
        public Decimal Amount { get; set; }

        public resultMatrix(AggregateResult ar) {
            WorkGroup = (String) ar.get('Work_Group__c');
            StageName = (String) ar.get('StageName');
            Amount = (Decimal) ar.get('expr0');
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<resultMatrix> getOpportunityMatrix() {
        return ReportResourceController.getOpportunityMatrix();
    }
}